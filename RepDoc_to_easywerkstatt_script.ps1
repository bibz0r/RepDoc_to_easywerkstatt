function Export-QueryToCsv {
    param (
        [string]$serverName,
        [string]$databaseName,
        [string]$query,
        [string]$csvFileName,
        [bool]$useWindowsAuthentication,
        [string]$userId = $null,
        [string]$password = $null
    )

    # Erstellen der Verbindungszeichenfolge
    if ($useWindowsAuthentication) {
        $connectionString = "Server=$serverName; Database=$databaseName; Integrated Security=True;"
    } else {
        $connectionString = "Server=$serverName; Database=$databaseName; User Id=$userId; Password=$password;"
    }

    # Erstellen und Öffnen der Verbindung
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString
    $connection.Open()

    # Ausführen der Abfrage
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $result = $command.ExecuteReader()

    # Erstellen eines DataTable und Laden der Ergebnisse
    $dataTable = New-Object System.Data.DataTable
    $dataTable.Load($result)

    # Exportieren der Ergebnisse in eine CSV-Datei
    $dataTable | Export-Csv -Path $csvFileName -NoTypeInformation -Ecnoding UTF8

    # Schließen der Verbindung
    $connection.Close()
}

# Variablen definieren
$serverName = "TB-PC0842" 
$databaseName = "Repdoc"
$useWindowsAuthentication = $true



# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#
#               Kunden 
# 
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
$query = @"
SELECT 
    KundenNr,
    Anrede,
    Name,
    Telefon,
    Mobil,
    eMail,
    StrasseNr,
    PLZ,
    Ort,
    Land,
    GebDatum,
    WannErstellt
FROM [Repdoc].[dbo].[Kunden]
WHERE  
    WannErstellt >= '2021-09-01'
"@
Export-QueryToCsv -serverName $serverName -databaseName $databaseName -query $query -csvFileName "Kunden.csv" -useWindowsAuthentication $useWindowsAuthentication





# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#
#               Fahrzeuge 
# 
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
$query = @"
SELECT 
	k.KundenNr as "Client ID",
	kf.Hersteller as "Hersteller",
	kf.Fahrzeugtyp as "Fahrzeugtyp",
	kf.HandelsBezeichnung as "Modell",
	kf.Kennzeichen as "Kennzeichen",
	kf.ErstZulassung as "Erstzulassung",
	kf.NextDatumTuv as "Nächste §57A Überprüfung",
	kf.kmStand as "KM-Stand",
	CURRENT_TIMESTAMP AS "KM-Stand Datum",
	kf.FahrzeugIdNr as "Fahrgestellnummer",
	kf.MotorKennziffer as "Motor-Code",
	kf.PS as "Leistung",
	kf.Leergewicht as "Eigengewicht",
	kf.Hubraum as "Hubraum",
	kf.Fahrzeugklasse as "Fahrzeugklasse",
	kf.MerkmAussFarbcode as "Farb-Code",
	kf.GetriebeKennung as "Getriebe",
	kf.CodeKraftstoff as "Motor-Kategorie",
	kf.MerkmAussMetLackTyp as "Farbe"
FROM [Repdoc].[dbo].[KundenFahrzeuge] kf
LEFT JOIN Kunden k ON k.Id = kf.KundenId
WHERE k.WannErstellt >= '2021-09-01'
"@
Export-QueryToCsv -serverName $serverName -databaseName $databaseName -query $query -csvFileName "Fahrzeuge.csv" -useWindowsAuthentication $useWindowsAuthentication



