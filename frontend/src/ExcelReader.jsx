import React, { useEffect, useState } from "react";
import * as XLSX from "xlsx";

const ExcelReader = ({ recipients, setRecipients }) => {
  const [file, setFile] = useState(null);

  const handleFileUpload = (event) => {
    setFile(event.target.files[0]);

    if (file) {
      const reader = new FileReader();

      reader.onload = (e) => {
        const data = new Uint8Array(e.target.result);
        const workbook = XLSX.read(data, { type: "array" });

        // Assuming the phone numbers are in the first sheet
        const sheetName = workbook.SheetNames[0];
        const worksheet = workbook.Sheets[sheetName];

        // Convert sheet data to JSON
        const jsonData = XLSX.utils.sheet_to_json(worksheet, { header: 1 });

        // Extract phone numbers from the JSON data
        // This example assumes phone numbers are in the second column (index 1)
        // Adjust the index based on your Excel file's structure
        const extractedNumbers = jsonData
          .map((row, index) => {
            if (index !== 0) {
              return row[1];
            }
          })
          .filter(Boolean); // Filter out empty or undefined values

        setRecipients(extractedNumbers.join(", "));
        setFile(null);
      };

      reader.readAsArrayBuffer(file);
    }
  };

  return (
    <div>
      <input type="file" accept=".xls,.xlsx" onChange={handleFileUpload} />
      <div>
        <h2>Recipients:</h2>
        <input
          value={recipients}
          onChange={(e) => setRecipients(e.target.value)}
          style={{ width: "100%" }}
        />
      </div>
    </div>
  );
};

export default ExcelReader;
