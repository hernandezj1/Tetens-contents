import os
from saxonche import PySaxonProcessor

XSLT_PATH = "transform2.xsl"    # your stylesheet
OUTPUT_DIR = "chapter_files"             # output directory
INPURT_DIR = "input_files"              # input directory for XML files


with PySaxonProcessor(license=False) as proc:
    xslt_proc = proc.new_xslt30_processor()
    stylesheet = xslt_proc.compile_stylesheet(stylesheet_file=XSLT_PATH)

    # List all XML files in the input directory
    xml_files = [f for f in os.listdir(INPURT_DIR) if f.endswith('.xml')]

    for xml_file in xml_files:
        label = os.path.splitext(xml_file)[0]  # Extract label from filename
        print(f"Processing: {label}")

        # Read XML file from input_files
        xml_file_path = os.path.join(INPURT_DIR, xml_file)
        if not os.path.exists(xml_file_path):
            print(f"Error: XML file {xml_file_path} does not exist.")
            continue

        # transform
        result = stylesheet.transform_to_string(source_file=xml_file_path)

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

