$data = import-csv c:\temp\data.csv
$totalqty = 0
$totalsold = 0
$totalbought = 0
foreach ($line in $data) {

    if ($line.transaction -eq 'buy'){
        #buy transaction (we sold)
        $totalqty -= $line.qty
        $totalsold = $line.total } else {
        #sell transaction  (we bought)
        $totalqty += $line.qty
        $totalbought = $line.total
        }#end of else
    }#end of foreach
"totalqty,totalbought,totalsold,totalamt" | out-file c:\temp\summary.csv
"$totalqty,$totalbought,$totalsold,$($totalbought-$totalsold)" |
out-file c:\temp\summary.csv -Append