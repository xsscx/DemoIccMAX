import os
import logging
import re
from datetime import datetime

# Setup logging
logging.basicConfig(filename='scan_log.log', level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def log_banner():
    logging.info("------------------------------------------------")
    logging.info("Starting the code scan for suspicious characters and key sequences that may trigger system actions")
    logging.info(f"Scan started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    logging.info("------------------------------------------------")

def scan_directory(path):
    # Regex to detect patterns that might trigger print dialogs or other actions (e.g., ASCII control characters)
    # Adding common sequences that could be problematic, such as Form Feed (new page), Escape sequences, etc.
    problematic_sequences_regex = re.compile(
        r'\x0C'  # Form Feed
        r'|\x1B\[.*?m'  # ANSI Escape sequences that could change terminal state
        r'|\x1B[PX^_].*?\x1B\\'  # Device control strings
        r'|\x1B\]0;.*?\x07'  # Operating system command
        r'|\x10'  # Data Link Escape
        r'|\x13',  # Device Control 3 (XOFF)
        flags=re.DOTALL)

    for root, dirs, files in os.walk(path):
        for file in files:
            if file.endswith(('.cpp', '.h', '.mak', '.mk', 'Makefile', 'CMakeLists.txt', '.cmake')):
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                        content = f.read()
                        matches = problematic_sequences_regex.findall(content)
                        if matches:
                            message = f"Suspicious sequences found in {file_path}: {matches}"
                            logging.info(message)
                except Exception as e:
                    logging.error(f"Error processing {file_path}: {str(e)}")

def main():
    log_banner()
    scan_directory('/mnt/DemoIccMAX-master')  # Adjust the path to your project directory
    logging.info("Scan completed.")
    logging.info("------------------------------------------------")

if __name__ == "__main__":
    main()
