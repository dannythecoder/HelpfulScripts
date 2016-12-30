# This creates a window based on the XAML produced from a WPF project in Visual Studio.
# Based on this tutorial series: https://foxdeploy.com/2015/04/10/part-i-creating-powershell-guis-in-minutes-using-visual-studio-a-new-hope/

# After changing the XAML, update the section below labeled "Actually make the objects work"
# The object names will be the same as the names in Visual Studio, but with "WPF" appended to the front.

# Place the XAML (straight out of the Visual Studio form builder) between the @" "@
$inputXML = @"
<Window x:Class="WpfApplication1.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfApplication1"
        mc:Ignorable="d"
        Title="Configuration Builder" Height="350" Width="525">
    <Grid>
        <TextBlock x:Name="overview" HorizontalAlignment="Left" Margin="115,10,0,0" TextWrapping="Wrap" Text="Update these fields to build a configuration string" VerticalAlignment="Top" FontSize="16"/>
        <Button x:Name="btnCreate" Content="Create" Margin="0,0,10,10" Height="20" VerticalAlignment="Bottom" HorizontalAlignment="Right" Width="75"/>
        <Label x:Name="lblConfigName" Content="Configuration Name:" HorizontalAlignment="Left" Margin="115,36,0,0" VerticalAlignment="Top"/>
        <TextBox x:Name="textConfigName" Margin="240,39,0,0" TextWrapping="Wrap" Text="Default" Height="23" VerticalAlignment="Top" HorizontalAlignment="Left" Width="120"/>
        <Rectangle x:Name="HappyShape" Fill="#FF51C751" HorizontalAlignment="Left" Height="100" Margin="10,10,0,0" Stroke="#FF3E5FF3" VerticalAlignment="Top" Width="100" RadiusX="25" RadiusY="25" StrokeThickness="4"/>
        <Label x:Name="lblMaxVal" Content="Max Value:" HorizontalAlignment="Left" Margin="168,67,0,0" VerticalAlignment="Top"/>
        <Label x:Name="lblMinVal" Content="Min Value:" HorizontalAlignment="Left" Margin="170,98,0,0" VerticalAlignment="Top"/>
        <TextBox x:Name="textMaxVal" Margin="240,71,0,0" TextWrapping="Wrap" Text="100" Height="23" VerticalAlignment="Top" HorizontalAlignment="Left" Width="120"/>
        <TextBox x:Name="textMinVal" Margin="240,102,0,0" TextWrapping="Wrap" Text="0" Height="23" VerticalAlignment="Top" HorizontalAlignment="Left" Width="120"/>
        <Label x:Name="lblResult" Content="Result:" HorizontalAlignment="Left" Margin="10,130,0,0" VerticalAlignment="Top"/>
        <TextBlock x:Name="textResult" HorizontalAlignment="Left" Margin="60,131,0,0" TextWrapping="Wrap" VerticalAlignment="Top" FontSize="16" Text=" "/>

    </Grid>
</Window>

"@       
 
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'
 
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML

#Read XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try {
    $Form=[Windows.Markup.XamlReader]::Load( $reader )
}
catch {
    Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .NET is installed."
}
 
#===========================================================================
# Store Form Objects In PowerShell
#===========================================================================
 
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}
 
Function Get-FormVariables {
    if ($global:ReadmeDisplay -ne $true) {
        Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true
    }
    write-host "Found the following interactable elements on the form" -ForegroundColor Cyan
    get-variable WPF*
}
 
Get-FormVariables
 
#===========================================================================
# Actually make the objects work
#===========================================================================
 
$WPFbtnCreate.Add_Click({
    $config = "name=" + $WPFtextConfigName.Text + ";max=" + $WPFtextMaxVal.Text + ";min=" + $WPFtextMinVal.Text + ";"
    $WPFtextResult.Text = $config
    #$form.Close()
})

#Sample entry of how to add data to a list view
 
#$vmpicklistView.items.Add([pscustomobject]@{'VMName'=($_).Name;Status=$_.Status;Other="Yes"})
 
#===========================================================================
# Show the form
#===========================================================================
#write-host "To show the form, run the following" -ForegroundColor Cyan '$Form.ShowDialog() | out-null'
write-host "Starting the form..." -ForegroundColor Cyan

$Form.ShowDialog() | out-null
