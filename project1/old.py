import google.generativeai as genai
import os
from pathlib import Path
import fitz
from PIL import Image
import io
import glob

genai.configure(api_key="AIzaSyAFTbOTqPhtHmSmnpilSeCrY2lFBJNgiNE")
model = genai.GenerativeModel('gemini-1.5-flash')

class PDFQASystem:
    def __init__(self):
        self.pdf_content = ""
        self.pdf_filename = ""
        
    def pdf_to_images(self, pdf_path):
        """Convert PDF pages to images for OCR processing"""
        doc = fitz.open(pdf_path)
        images = []
        
        for page_num in range(len(doc)):
            page = doc.load_page(page_num)
            mat = fitz.Matrix(2.0, 2.0)  
            pix = page.get_pixmap(matrix=mat)
            img_data = pix.tobytes("png")

            img = Image.open(io.BytesIO(img_data))
            images.append(img)
            
        doc.close()
        return images

    def extract_text_from_image(self, image_pil, prompt="Extract all text content from this image"):
        """Extract text from image using Gemini Vision"""
        try:
            img_byte_arr = io.BytesIO()
            image_pil.save(img_byte_arr, format='PNG')
            image_data = img_byte_arr.getvalue()
            
            response = model.generate_content([
                prompt,
                {"mime_type": "image/png", "data": image_data}
            ])
            
            return response.text
        except Exception as e:
            return f"Error extracting text from image: {str(e)}"

    def extract_content_from_pdf(self, pdf_path):
        """Extract content from PDF using OCR via Gemini"""
        if not os.path.exists(pdf_path):
            return "PDF file not found!"
        
        try:
            print(f"Processing PDF: {pdf_path}")
            images = self.pdf_to_images(pdf_path)
            
            all_content = []
            prompt = "Extract all text content from this PDF page. Maintain formatting and structure where possible. Include all details, numbers, dates, and any other information."
            
            for i, img in enumerate(images):
                print(f"Processing page {i+1}/{len(images)}...")
                content = self.extract_text_from_image(img, prompt)
                all_content.append(f"--- Page {i+1} ---\n{content}")
            
            return "\n\n".join(all_content)
        
        except Exception as e:
            return f"Error processing PDF: {str(e)}"

    def find_pdf_files(self, folder_path="."):
        """Find all PDF files in the specified folder"""
        pdf_files = glob.glob(os.path.join(folder_path, "*.pdf"))
        return pdf_files

    def load_pdf_content(self, pdf_path=None):
        """Load and extract content from PDF"""
        if pdf_path is None:
            pdf_files = self.find_pdf_files()
            
            if not pdf_files:
                print("No PDF files found in current directory!")
                return False
            
            if len(pdf_files) == 1:
                pdf_path = pdf_files[0]
                print(f"Found PDF: {pdf_path}")
            else:
                print("Multiple PDF files found:")
                for i, pdf_file in enumerate(pdf_files):
                    print(f"{i+1}. {os.path.basename(pdf_file)}")
                
                while True:
                    try:
                        choice = int(input("Select PDF number: ")) - 1
                        if 0 <= choice < len(pdf_files):
                            pdf_path = pdf_files[choice]
                            break
                        else:
                            print("Invalid choice. Please try again.")
                    except ValueError:
                        print("Please enter a valid number.")
        
        self.pdf_filename = os.path.basename(pdf_path)
        print(f"\nExtracting content from: {self.pdf_filename}")
        print("This may take a few moments...")
        
        self.pdf_content = self.extract_content_from_pdf(pdf_path)
        
        if "Error" in self.pdf_content:
            print(f"Error loading PDF: {self.pdf_content}")
            return False
        
        print(f"\n✅ Successfully extracted content from {self.pdf_filename}")
        print(f"Content length: {len(self.pdf_content)} characters")
        return True

    def ask_question(self, question):
        """Ask a question about the PDF content"""
        if not self.pdf_content:
            return "No PDF content loaded. Please load a PDF first."
        prompt = f"""
Based on the following PDF content from "{self.pdf_filename}", please answer the user's question accurately and comprehensively.

PDF CONTENT:
{self.pdf_content}

USER QUESTION: {question}

Please provide a detailed answer based solely on the information contained in the PDF. If the information is not available in the PDF, please state that clearly.
"""
        
        try:
            response = model.generate_content(prompt)
            return response.text
        except Exception as e:
            return f"Error generating response: {str(e)}"

    def show_pdf_summary(self):
        """Generate a summary of the PDF content"""
        if not self.pdf_content:
            return "No PDF content loaded."
        
        prompt = f"""
Please provide a comprehensive summary of the following PDF content from "{self.pdf_filename}":

{self.pdf_content}

Include:
1. Main topics covered
2. Key information and data
3. Important dates, numbers, or facts
4. Document structure/sections
"""
        
        try:
            response = model.generate_content(prompt)
            return response.text
        except Exception as e:
            return f"Error generating summary: {str(e)}"

def main():
    print("=== PDF Q&A System with Gemini ===")
    print("This system will extract content from your PDF and allow you to ask questions about it.")
    print("-" * 60)
    
    qa_system = PDFQASystem()
    
    # Load PDF content
    if not qa_system.load_pdf_content():
        return
    
    print("\n" + "="*60)
    print("PDF SUMMARY:")
    print("="*60)
    summary = qa_system.show_pdf_summary()
    print(summary)
    
    print("\n" + "="*60)
    print("ASK QUESTIONS ABOUT YOUR PDF:")
    print("="*60)
    print("Commands:")
    print("- Type your question to get an answer")
    print("- 'summary' - Show PDF summary again")
    print("- 'content' - Show raw extracted content")
    print("- 'reload' - Load a different PDF")
    print("- 'quit' - Exit")
    print("-" * 60)
    
    while True:
        question = input(f"\n💬 Ask about '{qa_system.pdf_filename}': ").strip()
        
        if question.lower() == 'quit':
            print("Goodbye!")
            break
        elif question.lower() == 'summary':
            print("\n" + "="*60)
            print("PDF SUMMARY:")
            print("="*60)
            print(qa_system.show_pdf_summary())
        elif question.lower() == 'content':
            print("\n" + "="*60)
            print("RAW EXTRACTED CONTENT:")
            print("="*60)
            print(qa_system.pdf_content)
        elif question.lower() == 'reload':
            if qa_system.load_pdf_content():
                print("\n" + "="*60)
                print("NEW PDF SUMMARY:")
                print("="*60)
                print(qa_system.show_pdf_summary())
        elif question.strip():
            print(f"\n🤔 Analyzing question about '{qa_system.pdf_filename}'...")
            answer = qa_system.ask_question(question)
            print("\n" + "="*60)
            print("ANSWER:")
            print("="*60)
            print(answer)
        else:
            print("Please enter a question or command.")

def quick_pdf_qa(pdf_path, question):
    """Quick function to ask a question about a PDF"""
    qa_system = PDFQASystem()
    if qa_system.load_pdf_content(pdf_path):
        return qa_system.ask_question(question)
    return "Failed to load PDF"

def quick_pdf_summary(pdf_path):
    """Quick function to get PDF summary"""
    qa_system = PDFQASystem()
    if qa_system.load_pdf_content(pdf_path):
        return qa_system.show_pdf_summary()
    return "Failed to load PDF"

def example_usage():
    """Example of how to use the system"""
    
    
    pdf_file = "document.pdf" 
    
    summary = quick_pdf_summary(pdf_file)
    print("Summary:", summary)
    
    answer1 = quick_pdf_qa(pdf_file, "What are the main topics covered?")
    answer2 = quick_pdf_qa(pdf_file, "What dates are mentioned?")
    answer3 = quick_pdf_qa(pdf_file, "What are the key numbers or amounts?")
    
    print("Q1:", answer1)
    print("Q2:", answer2)
    print("Q3:", answer3)

if __name__ == "__main__":
    main()
