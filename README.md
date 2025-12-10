# ETL Processing Script

-------------------------------------
How to run the script
-------------------------------------
Usage:
    ./etl.sh (private-key) (remote-server) (remote-user) (remote-file) (mysql-user) (mysql-db)


-------------------------------------
What the script does
-------------------------------------
01. Transfer the remote .csv.bz2 file using scp and your private key.
02. Decompresses the .bz2 file to produce transaction.csv.
03. Remove the header row.
04. Convert all text to lowercase.
05. Standardizes the gender field (m, f, u).
06. Filters missing/invalid states into exception.csv
07. Cleans purchase amount (removes '$' and formats to 2 decimals).
08. Sorts transaction.csv by CustomerID.
09. Creates summary.csv:
    - customerID, state, zip, lastname, firstname, total purchase
    - Sorted by: state, zip DESC, lastname, firstname
10. Generates transaction.rpt:
    - Transaction count per state
    - Sorted by count DESC then state
11. Generates purchase.rpt:
    - Total purchase amount by state/gender
    - Rounded to nearest 100
    - Sorted by amount DESC, then state, then gender

-------------------------------------
Files Produced by Script
-------------------------------------
- transaction.csv (Cleaned Data)
- exceptions.csv
- summary.csv
- transaction.rpt
- purchase.rpt

-------------------------------------
Notes
-------------------------------------
- Script requires standard Linux tools (awk, sed, tr, sort, scp, bunzip2).
- Script includes error checking and usage statement.
- No hard-coded paths; all arguments supplied at runtime.

-------------------------------------
Check before running the script
-------------------------------------
- There should be just 2 files inside the folder. Which are README.md and etl.sh. All other files should be deleted.
- Remove # from line 321. That line is commented out because this project was being uploaded to GitHub.
- Make sure you have a server, and there is a proper CSV file inside a .bz2 compression.
- If you don't have a server, you should comment out steps 1 and 2.
- If you don't have CSV stored on the server, but as a bz2 zip. You should comment on step 1.
- If you have a CSV file locally and it is not compressed. You should comment out steps 1 and 2, and add the line **mv (absolute-path-to-file)/(your-filename).csv transaction.csv** before line 65.

-------------------------------------
Author
-------------------------------------
**Shivam Patel** <br>
Course: CSCI 5305 - Linux/Unix System
University of Central Arkansas - Department of Computer Science
LinkedIn: https://www.linkedin.com/in/shivampatel19/

