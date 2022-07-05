#!/usr/bin/env pwsh

function Main([string[]] $mainargs) {
Get-AzSubscription | ? {
  if ($mainargs -and $mainargs.Count -eq 1) {
    $_.Name.ToLower().StartsWith($mainargs[0])
  }
  else {
    $true
  }
} | % {
  [string] $sub = $_.Name
  Set-AzContext -SubscriptionId $_.Id | Out-Null
  Get-AzPolicyExemption | % {
    $o = $_
    $o | Add-Member NoteProperty "SubscriptionName" $sub
    $o
  }
} | % {
  $oo = $_.Properties
  $oo | Add-Member NoteProperty "PolicyName" $_.Name
  $oo | Add-Member NoteProperty "SubscriptionName" $_.SubscriptionName
  $oo | Add-Member NoteProperty "ResourceId" $_.ResourceId
  $oo
} | Sort-Object SubscriptionName,PolicyName,DisplayName | Select-Object -ExcludeProperty PolicyDefinitionReferenceIds,ExemptionCategory,Metadata | % {
  $_.PolicyAssignmentId = $_.PolicyAssignmentId.Substring(49)
  $_
} | ? {
  !$_.ExpiresOn
} | ft -a
}

Main $args
