# Villi’s Cafe final report package

The submission-ready Word report is `Villis_Cafe_Final_Report.docx`.
The editable demonstration deck is
`presentation/Villis_Cafe_Project_Demonstration.pptx`.

## Included evidence

- `screenshots/`: selected 1080 × 2400 captures from the running Pixel 7 Android 16 emulator
- `diagrams/`: project-specific use case, layered architecture, and SQLite ER diagrams
- `generate_report.py`: reproducible source used to generate the DOCX
- `presentation/`: 15-slide PowerPoint, presenter guide, and reproducible generator

## Required personal checks before submission

Open the DOCX in Microsoft Word and complete every highlighted or bracketed field:

1. Student reference number
2. Deadline date
3. Member of staff
4. Programme
5. Group/individual declaration and any additional participant contributions
6. Signature and submission date
7. Public/evaluator-accessible Plymouth OneDrive source-code link (mandatory in the supplied guideline)

Personal-name fields were intentionally left blank. The report transparently declares OpenAI Codex as a writing/formatting aid. In Word, update the Table of Contents field if page numbers are not populated automatically.

The PowerPoint is paced for a 10-minute project demonstration followed by a
5-minute individual-contribution section. Speaker notes are included on every
slide, and slides 14–15 provide backup evidence if the live application cannot
be shown during recording.

## Verification recorded on 25 August 2026

- Android debug APK built and installed successfully
- Application completed the customer ordering journey on emulator-5554
- `flutter analyze`: no issues found
- `flutter test`: all 42 tests passed
- DOCX archive integrity: passed
