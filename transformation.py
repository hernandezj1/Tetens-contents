import os
import csv
import requests
import tempfile
from saxonche import PySaxonProcessor


CSV_PATH = "files.csv"                   # path to your csv
XSLT_PATH = "transform.xsl"    # your stylesheet
OUTPUT_DIR = "chapter_files"             # output directory

# ensure output directory exists
os.makedirs(OUTPUT_DIR, exist_ok=True)

with PySaxonProcessor(license=False) as proc:
    xslt_proc = proc.new_xslt30_processor()
    stylesheet = xslt_proc.compile_stylesheet(stylesheet_file=XSLT_PATH)

    with open(CSV_PATH, newline='', encoding="utf-8") as csvfile:
        reader = csv.reader(csvfile)
        next(reader)  # skip header: Title,URL

        for row in reader:

            label, url = row[0].strip(), row[1].strip()
            print(f"Processing: {label} | {url}")

            # fetch TEI XML content from Mikes repo
            response = requests.get(url)
            response.raise_for_status()
            xml_content = response.text

            # save to temporary XML file
            with tempfile.NamedTemporaryFile("w", suffix=".xml", delete=False, encoding="utf-8") as tmp_file:
                tmp_file.write(xml_content)
                tmp_file_path = tmp_file.name

            # transform
            result = stylesheet.transform_to_string(source_file=tmp_file_path)

            # generate safe output filename
            safe_name = "".join(c for c in label if c.isalnum() or c in ('-', '_')).strip()
            if not safe_name:
                safe_name = "output"
            output_file = os.path.join(OUTPUT_DIR, f"{safe_name}.html")

            # write output
            with open(output_file, "w", encoding="utf-8") as f:
                f.write(result)

            print(f" Saved → {output_file}")

print("\nAll transformations completed successfully!")
