import sys
import subprocess

try:
    import pypdf
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "pypdf"])
    import pypdf

try:
    reader = pypdf.PdfReader('Tieuchiduan.pdf')
    with open('pdf_out.txt', 'w', encoding='utf-8') as f:
        for page in reader.pages:
            f.write(page.extract_text() + '\n')
    print("PDF extracted successfully to pdf_out.txt")
except Exception as e:
    print(f"Error: {e}")
