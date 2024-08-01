import pandas as pd
import glob
from tabulate import tabulate
csv_files = glob.glob('W1/*.csv')
markdown_tables = []
for file in csv_files:
    df = pd.read_csv(file)
    markdown_table = tabulate(df, headers='keys', tablefmt='pipe', showindex=False)
    table_title = f"### {file.split('/')[-1].replace('.csv', '')}"
    markdown_tables.append(f"{table_title}\n\n{markdown_table}\n")

combined_markdown = "\n\n".join(markdown_tables)
with open('combined_results_1.md', 'w') as f:
    f.write(combined_markdown)
