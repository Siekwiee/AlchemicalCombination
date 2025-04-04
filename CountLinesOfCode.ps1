# Get all files recursively from src directory
$files = Get-ChildItem -Path ".\src" -Recurse -File

# Create a hashtable to store line counts by extension
$lineCountsByExtension = @{}

foreach ($file in $files) {
    # Get file extension (without the dot)
    $extension = $file.Extension.TrimStart('.')
    
    # Skip if extension is empty
    if ([string]::IsNullOrEmpty($extension)) {
        continue
    }
    
    # Count lines in the file
    $lineCount = (Get-Content $file.FullName | Measure-Object -Line).Lines
    
    # Add to or update the hashtable
    if ($lineCountsByExtension.ContainsKey($extension)) {
        $lineCountsByExtension[$extension] += $lineCount
    } else {
        $lineCountsByExtension[$extension] = $lineCount
    }
}

# Output results with nice formatting
Write-Host "`nLines of Code by File Type:`n" -ForegroundColor Cyan
Write-Host "------------------------" -ForegroundColor Cyan

$totalLines = 0
foreach ($extension in $lineCountsByExtension.Keys | Sort-Object) {
    $lines = $lineCountsByExtension[$extension]
    $totalLines += $lines
    Write-Host ("{0,-10} : {1,6:N0} lines" -f $extension, $lines)
}

Write-Host "------------------------" -ForegroundColor Cyan
Write-Host ("Total      : {0,6:N0} lines" -f $totalLines) -ForegroundColor Green
Write-Host ""
