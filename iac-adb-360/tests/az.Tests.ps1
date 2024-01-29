BeforeAll {
    $rgName = "rg-wus2-adbmidp1031-dev"
}

Describe "Test Azure Resources" {
    Context "Check if resource group exists" {
        It "Should return true if resource group exists" {
            $rg = Get-AzResourceGroup -Name $rgName
            $rg | Should -Not -BeNullOrEmpty
        }
    }
}