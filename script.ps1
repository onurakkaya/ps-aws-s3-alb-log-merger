# Download All files in the folder 
$sourceS3Bucket=s3://"#bucket-name#"/"#sub-dir#"/AWSLogs/"#account-id#"/elasticloadbalancing/eu-central-1/2023/08/28/
$destLocalPath=C:\S3_ALB_LOGS

aws s3 cp $sourceS3Bucket $destLocalPath --recursive

# Make folder structure to flat in Local Log Dir
Set-Location $destLocalPath
Get-ChildItem -Path .\*.log -Recurse -Force  | ForEach-Object {
    $counter = $counter + 1
    $SourcePath=$_
    $DestPath="$destLocalPath\merged\" + $(Split-Path -Path $_ -Leaf -Resolve)
    Write-Debug "Processing file: $SourcePath"
    Write-Debug "Destination Path is : $DestPath"
    If  ((Test-Path $DestPath) -eq $False && Test-Path -Path $SourcePath -PathType Leaf) {
        Copy-Item -Path "$SourcePath" -Destination "$DestPath" -Force
        Write-Output "File copied to dest path  '$DestPath' "
    }
    else {
        Write-Output "File already exists in dest path '$DestPath' skipping..."
        Write-Debug "Skipping file: $SourcePath"
    }
}

# Merge all log files into one file
$mergedLogPath="$destLocalPath\merged.mlog"
If (Test-Path $mergedLogPath) {
    Remove-Item -Path $mergedLogPath -Force
}
Get-ChildItem -Path ".\merged" -Recurse -Filter *.log | ForEach-Object { Get-Content $_.FullName } | Set-Content $mergedLogPath

# Open Merged log file via VS Code
code $mergedLogPath