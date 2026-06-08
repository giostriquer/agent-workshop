$ErrorActionPreference = "Stop"

function Fail {
    param([string]$Message)
    throw "native plugin validation failed: $Message"
}

function Has-Property {
    param(
        [Parameter(Mandatory = $true)] $Object,
        [Parameter(Mandatory = $true)] [string] $Name
    )

    return $Object.PSObject.Properties.Name -contains $Name
}

function Read-JsonFile {
    param([Parameter(Mandatory = $true)] [string] $Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Fail "missing JSON file: $Path"
    }

    try {
        return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    }
    catch {
        Fail "invalid JSON in ${Path}: $($_.Exception.Message)"
    }
}

function Get-RelativeFileList {
    param([Parameter(Mandatory = $true)] [string] $Root)

    if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
        Fail "missing directory: $Root"
    }

    $resolvedRoot = (Resolve-Path -LiteralPath $Root).Path
    return Get-ChildItem -LiteralPath $resolvedRoot -Recurse -File |
        ForEach-Object { $_.FullName.Substring($resolvedRoot.Length + 1).Replace("\", "/") } |
        Sort-Object
}

function Assert-SameFile {
    param(
        [Parameter(Mandatory = $true)] [string] $ExpectedPath,
        [Parameter(Mandatory = $true)] [string] $ActualPath
    )

    if (-not (Test-Path -LiteralPath $ExpectedPath -PathType Leaf)) {
        Fail "missing source file: $ExpectedPath"
    }
    if (-not (Test-Path -LiteralPath $ActualPath -PathType Leaf)) {
        Fail "missing mirrored file: $ActualPath"
    }

    $expectedBytes = [System.IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $ExpectedPath).Path)
    $actualBytes = [System.IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $ActualPath).Path)
    if ([System.Linq.Enumerable]::SequenceEqual($expectedBytes, $actualBytes)) {
        return
    }

    $expectedText = ([System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $ExpectedPath).Path) -replace "`r`n", "`n")
    $actualText = ([System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $ActualPath).Path) -replace "`r`n", "`n")
    if ($expectedText -ne $actualText) {
        Fail "file differs from source: $ActualPath"
    }
}

function Assert-SameFileList {
    param(
        [Parameter(Mandatory = $true)] [string[]] $Expected,
        [Parameter(Mandatory = $true)] [string[]] $Actual,
        [Parameter(Mandatory = $true)] [string] $Context
    )

    $diff = Compare-Object $Expected $Actual
    if ($diff) {
        $details = ($diff | ForEach-Object { "$($_.SideIndicator) $($_.InputObject)" }) -join "; "
        Fail "$Context file list mismatch: $details"
    }
}

function Assert-SingleSkill {
    param(
        [Parameter(Mandatory = $true)] [string] $SkillsRoot,
        [Parameter(Mandatory = $true)] [string] $ExpectedName
    )

    if (-not (Test-Path -LiteralPath $SkillsRoot -PathType Container)) {
        Fail "missing skills root: $SkillsRoot"
    }

    $skills = @(Get-ChildItem -LiteralPath $SkillsRoot -Directory | Select-Object -ExpandProperty Name)
    if ($skills.Count -ne 1 -or $skills[0] -ne $ExpectedName) {
        Fail "$SkillsRoot must expose only $ExpectedName"
    }
}

function Assert-OnlyAllowedPluginSkillFiles {
    $pluginRoot = "plugins/agent-workshop"
    $allowedSkillFile = "plugins/agent-workshop/skills/agent-workshop-onboard/SKILL.md"

    $skillFiles = @(Get-ChildItem -LiteralPath $pluginRoot -Recurse -File -Filter "SKILL.md" |
        ForEach-Object { $_.FullName.Replace((Resolve-Path ".").Path + "\", "").Replace("\", "/") })

    if ($skillFiles.Count -ne 1 -or $skillFiles[0] -ne $allowedSkillFile) {
        $details = ($skillFiles -join "; ")
        Fail "plugin payload must contain only the active onboarding SKILL.md; found: $details"
    }
}

function Assert-OnlyAllowedPluginAgents {
    $pluginRoot = "plugins/agent-workshop"
    $allowedAgentFile = "plugins/agent-workshop/skills/agent-workshop-onboard/agents/openai.yaml"
    $allowedAgentDir = "plugins/agent-workshop/skills/agent-workshop-onboard/agents"

    if (Test-Path -LiteralPath "agents" -PathType Container) {
        Fail "root agents/ would expose active plugin agents"
    }
    if (Test-Path -LiteralPath "$pluginRoot/agents" -PathType Container) {
        Fail "$pluginRoot/agents would expose active plugin agents"
    }

    $agentDirs = @(Get-ChildItem -LiteralPath $pluginRoot -Recurse -Directory |
        Where-Object { $_.Name -eq "agents" } |
        ForEach-Object { $_.FullName.Replace((Resolve-Path ".").Path + "\", "").Replace("\", "/") })

    foreach ($dir in $agentDirs) {
        if ($dir -like "*/references/*") {
            continue
        }
        if ($dir -ne $allowedAgentDir) {
            Fail "unexpected active agents directory in plugin payload: $dir"
        }
    }

    $activeAgentFiles = @(Get-ChildItem -LiteralPath $allowedAgentDir -File -ErrorAction SilentlyContinue |
        ForEach-Object { $_.FullName.Replace((Resolve-Path ".").Path + "\", "").Replace("\", "/") })

    if ($activeAgentFiles.Count -ne 1 -or $activeAgentFiles[0] -ne $allowedAgentFile) {
        Fail "Codex skill wrapper must be the only active agent wrapper"
    }
}

function Assert-ReviewersPlugin {
    $root = "plugins/reviewers"
    $manifest = Read-JsonFile "$root/.claude-plugin/plugin.json"

    if ($manifest.name -ne "reviewers") {
        Fail "reviewers plugin name must be reviewers"
    }
    if (Has-Property $manifest "mcpServers") {
        Fail "reviewers manifest must not contain mcpServers"
    }
    $skillsDir = "$root/skills"
    if (-not (Test-Path -LiteralPath $skillsDir -PathType Container)) {
        Fail "reviewers must contain a skills directory"
    }
    $expectedSkills = @("handoff-pr", "handoff-review")
    $actualSkills = @(Get-ChildItem -LiteralPath $skillsDir -Directory | Select-Object -ExpandProperty Name | Sort-Object)
    Assert-SameFileList $expectedSkills $actualSkills "reviewers skills"
    foreach ($skillName in $expectedSkills) {
        Assert-SameFile ".claude/skills/$skillName/SKILL.md" "$skillsDir/$skillName/SKILL.md"
    }

    $agentDir = "$root/agents"
    if (-not (Test-Path -LiteralPath $agentDir -PathType Container)) {
        Fail "reviewers must contain an agents directory"
    }

    $expected = @("pattern-reviewer.md", "spec-reviewer.md", "test-quality-reviewer.md", "vigil.md")
    $actual = @(Get-ChildItem -LiteralPath $agentDir -File | Select-Object -ExpandProperty Name | Sort-Object)
    Assert-SameFileList $expected $actual "reviewers agents"

    foreach ($name in $expected) {
        Assert-SameFile ".claude/agents/$name" "$agentDir/$name"
    }
}

function Assert-ReferenceSetMatchesSources {
    param([Parameter(Mandatory = $true)] [string] $ReferenceRoot)

    Assert-SameFile "marketplace/catalog.json" "$ReferenceRoot/catalog.json"

    foreach ($file in Get-ChildItem -LiteralPath ".claude/agents" -File) {
        Assert-SameFile $file.FullName "$ReferenceRoot/agents/$($file.Name)"
    }
    foreach ($file in Get-ChildItem -LiteralPath ".codex/agents" -File) {
        Assert-SameFile $file.FullName "$ReferenceRoot/wrappers/codex/$($file.Name)"
    }
    foreach ($file in Get-ChildItem -LiteralPath ".gemini/agents" -File) {
        Assert-SameFile $file.FullName "$ReferenceRoot/wrappers/gemini/$($file.Name)"
    }
    foreach ($file in Get-ChildItem -LiteralPath ".opencode/agents" -File) {
        Assert-SameFile $file.FullName "$ReferenceRoot/wrappers/opencode/$($file.Name)"
    }
    foreach ($skill in Get-ChildItem -LiteralPath ".claude/skills" -Directory) {
        Assert-SameFile "$($skill.FullName)/SKILL.md" "$ReferenceRoot/skills/$($skill.Name).md"
    }

    foreach ($name in "agents", "skills", "conventions", "marketplace") {
        $sourceRoot = "docs/$name"
        $targetRoot = "$ReferenceRoot/docs/$name"
        foreach ($file in Get-ChildItem -LiteralPath $sourceRoot -File) {
            Assert-SameFile $file.FullName "$targetRoot/$($file.Name)"
        }
    }
}

$claudeManifest = Read-JsonFile ".claude-plugin/plugin.json"
$claudeMarketplace = Read-JsonFile ".claude-plugin/marketplace.json"
$claudePayloadManifest = Read-JsonFile "plugins/agent-workshop/.claude-plugin/plugin.json"
$codexMarketplace = Read-JsonFile ".agents/plugins/marketplace.json"
$codexManifest = Read-JsonFile "plugins/agent-workshop/.codex-plugin/plugin.json"
$catalog = Read-JsonFile "marketplace/catalog.json"
$reviewersManifest = Read-JsonFile "plugins/reviewers/.claude-plugin/plugin.json"

if ($claudeManifest.name -ne "agent-workshop") {
    Fail "Claude plugin name must be agent-workshop"
}
if (Has-Property $claudeManifest "mcpServers") {
    Fail "Claude plugin manifest must not contain mcpServers"
}
if (Has-Property $claudeManifest "agents") {
    Fail "Claude plugin manifest must not expose agents"
}

$claudePlugins = @($claudeMarketplace.plugins)
if ($claudePlugins.Count -ne 2) {
    Fail "Claude marketplace must contain exactly two plugins (agent-workshop, reviewers)"
}
$onboardEntry = $claudePlugins | Where-Object { $_.name -eq "agent-workshop" }
$reviewersEntry = $claudePlugins | Where-Object { $_.name -eq "reviewers" }
if (-not $onboardEntry) {
    Fail "Claude marketplace must contain the agent-workshop plugin"
}
if (-not $reviewersEntry) {
    Fail "Claude marketplace must contain the reviewers plugin"
}
if ($onboardEntry.source -ne "./plugins/agent-workshop") {
    Fail "agent-workshop marketplace source must be ./plugins/agent-workshop"
}
if ($onboardEntry.version -ne $claudeManifest.version) {
    Fail "agent-workshop marketplace version must match the plugin manifest"
}
if ($reviewersEntry.source -ne "./plugins/reviewers") {
    Fail "reviewers marketplace source must be ./plugins/reviewers"
}
if ($reviewersEntry.version -ne $reviewersManifest.version) {
    Fail "reviewers marketplace version must match its plugin manifest"
}

if ($claudePayloadManifest.name -ne "agent-workshop") {
    Fail "Claude plugin payload name must be agent-workshop"
}
if ($claudePayloadManifest.version -ne $claudeManifest.version) {
    Fail "Claude payload manifest version must match the root Claude manifest"
}
if (Has-Property $claudePayloadManifest "mcpServers") {
    Fail "Claude plugin payload manifest must not contain mcpServers"
}
if (Has-Property $claudePayloadManifest "agents") {
    Fail "Claude plugin payload manifest must not expose agents"
}

if ($codexMarketplace.plugins.Count -ne 1 -or $codexMarketplace.plugins[0].name -ne "agent-workshop") {
    Fail "Codex marketplace must contain only the agent-workshop plugin"
}
if ($codexMarketplace.plugins[0].source.path -ne "./plugins/agent-workshop") {
    Fail "Codex marketplace source path must be ./plugins/agent-workshop"
}
if ($codexMarketplace.plugins[0].policy.installation -ne "AVAILABLE") {
    Fail "Codex marketplace installation policy must be AVAILABLE"
}
if ($codexMarketplace.plugins[0].policy.authentication -ne "ON_INSTALL") {
    Fail "Codex marketplace authentication policy must be ON_INSTALL"
}
if (-not (Has-Property $codexMarketplace.plugins[0] "category")) {
    Fail "Codex marketplace entry must include category"
}

if ($codexManifest.name -ne "agent-workshop") {
    Fail "Codex plugin name must be agent-workshop"
}
if ($codexManifest.version -ne $claudeManifest.version) {
    Fail "Codex plugin manifest version must match the Claude manifest"
}
if ($codexManifest.skills -ne "./skills") {
    Fail "Codex plugin manifest must set skills to ./skills"
}
if (Has-Property $codexManifest "mcpServers") {
    Fail "Codex plugin manifest must not contain mcpServers"
}
if (Has-Property $codexManifest "apps") {
    Fail "Codex plugin manifest must not contain apps"
}
if (-not (Has-Property $codexManifest "interface") -or -not (Has-Property $codexManifest.interface "capabilities")) {
    Fail "Codex plugin manifest must declare interface.capabilities"
}
$capabilities = @($codexManifest.interface.capabilities)
if ($capabilities.Count -ne 1 -or $capabilities[0] -ne "Skills") {
    Fail "Codex plugin capabilities must be exactly Skills"
}

Assert-SingleSkill "skills" "agent-workshop-onboard"
Assert-SingleSkill "plugins/agent-workshop/skills" "agent-workshop-onboard"
Assert-OnlyAllowedPluginSkillFiles
Assert-OnlyAllowedPluginAgents
Assert-ReviewersPlugin

Assert-SameFile `
    "skills/agent-workshop-onboard/SKILL.md" `
    "plugins/agent-workshop/skills/agent-workshop-onboard/SKILL.md"
Assert-SameFile `
    ".claude-plugin/plugin.json" `
    "plugins/agent-workshop/.claude-plugin/plugin.json"

$rootReferenceRoot = "skills/agent-workshop-onboard/references"
$codexReferenceRoot = "plugins/agent-workshop/skills/agent-workshop-onboard/references"
$rootFiles = Get-RelativeFileList $rootReferenceRoot
$codexFiles = Get-RelativeFileList $codexReferenceRoot
Assert-SameFileList $rootFiles $codexFiles "root/Codex references"

foreach ($relativePath in $rootFiles) {
    Assert-SameFile "$rootReferenceRoot/$relativePath" "$codexReferenceRoot/$relativePath"
}

Assert-ReferenceSetMatchesSources $rootReferenceRoot

$catalogAgents = $catalog.agents.PSObject.Properties.Name | Sort-Object
foreach ($agentName in $catalogAgents) {
    $agentPath = "$rootReferenceRoot/agents/$agentName.md"
    if (-not (Test-Path -LiteralPath $agentPath -PathType Leaf)) {
        Fail "cataloged agent is missing from bundled agent references: $agentName"
    }
}

Write-Output "native plugin validation ok"
