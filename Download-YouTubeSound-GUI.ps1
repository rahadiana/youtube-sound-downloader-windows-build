Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()
$form = New-Object System.Windows.Forms.Form
$form.Text = 'YouTube Sound Downloader'; $form.Size = New-Object System.Drawing.Size(700,460); $form.StartPosition = 'CenterScreen'; $form.Font = New-Object System.Drawing.Font('Segoe UI',10)
$title = New-Object System.Windows.Forms.Label; $title.Text = 'YouTube Sound Downloader'; $title.Font = New-Object System.Drawing.Font('Segoe UI',18,[System.Drawing.FontStyle]::Bold); $title.Location = New-Object System.Drawing.Point(24,18); $title.Size = New-Object System.Drawing.Size(620,38); $form.Controls.Add($title)
function Label($text,$x,$y,$w,$h) { $c=New-Object System.Windows.Forms.Label; $c.Text=$text; $c.Location=New-Object System.Drawing.Point($x,$y); $c.Size=New-Object System.Drawing.Size($w,$h); $form.Controls.Add($c); return $c }
function TextBox($x,$y,$w,$h,$value) { $c=New-Object System.Windows.Forms.TextBox; $c.Location=New-Object System.Drawing.Point($x,$y); $c.Size=New-Object System.Drawing.Size($w,$h); $c.Text=$value; $form.Controls.Add($c); return $c }
Label 'URL atau Video ID:' 26 78 180 24 | Out-Null; $videoBox=TextBox 26 104 625 28 ''
Label 'Base URL API (sesuai konfigurasi layanan/Postman):' 26 145 500 24 | Out-Null; $baseBox=TextBox 26 171 625 28 'https://edge-1.nusantaracode.com'
Label 'Folder output:' 26 211 150 24 | Out-Null; $outBox=TextBox 26 237 510 28 (Join-Path $PSScriptRoot 'downloads')
$browse=New-Object System.Windows.Forms.Button; $browse.Text='Pilih...'; $browse.Location=New-Object System.Drawing.Point(546,235); $browse.Size=New-Object System.Drawing.Size(105,30); $form.Controls.Add($browse)
$browse.Add_Click({ $d=New-Object System.Windows.Forms.FolderBrowserDialog; $d.SelectedPath=$outBox.Text; if($d.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK){$outBox.Text=$d.SelectedPath} })
$download=New-Object System.Windows.Forms.Button; $download.Text='Ambil File Sound'; $download.Font=New-Object System.Drawing.Font('Segoe UI',10,[System.Drawing.FontStyle]::Bold); $download.Location=New-Object System.Drawing.Point(26,285); $download.Size=New-Object System.Drawing.Size(190,40); $form.Controls.Add($download)
$status=Label 'Siap. Masukkan URL/ID dan Base URL API.' 26 337 625 40
$note=Label 'Gunakan hanya untuk audio yang Anda berhak unduh. URL stream dapat kedaluwarsa.' 26 390 625 30; $note.ForeColor=[System.Drawing.Color]::DimGray
$download.Add_Click({
 $video=$videoBox.Text.Trim(); $base=$baseBox.Text.Trim(); $out=$outBox.Text.Trim()
 if(-not $video){[System.Windows.Forms.MessageBox]::Show('Masukkan URL atau Video ID.')|Out-Null;return}
 if(-not $base -or $base -notmatch '^https?://'){[System.Windows.Forms.MessageBox]::Show('Masukkan Base URL API yang benar.');return}
 if(-not $out){[System.Windows.Forms.MessageBox]::Show('Pilih folder output.');return}
 $download.Enabled=$false; $status.Text='Sedang mengambil detail video dan mengunduh audio...'; $form.Refresh()
 try { $scriptPath=Join-Path $PSScriptRoot 'Download-YouTubeSound.ps1'; if(-not(Test-Path $scriptPath)){throw 'Download-YouTubeSound.ps1 tidak ditemukan.'}; & $scriptPath -Video $video -BaseUrl $base -OutputDirectory $out; $status.Text='Selesai. Periksa folder output.'; [System.Windows.Forms.MessageBox]::Show(('Proses selesai. Folder output: '+$out),'Berhasil')|Out-Null }
 catch { $status.Text='Gagal: '+$_.Exception.Message; [System.Windows.Forms.MessageBox]::Show($_.Exception.Message,'Unduhan gagal')|Out-Null }
 finally { $download.Enabled=$true }
})
[void]$form.ShowDialog()
