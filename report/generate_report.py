from pathlib import Path
from textwrap import wrap

from PIL import Image, ImageDraw, ImageFont
from docx import Document
from docx.enum.section import WD_SECTION
from docx.enum.table import WD_CELL_VERTICAL_ALIGNMENT, WD_TABLE_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_BREAK, WD_LINE_SPACING
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Cm, Inches, Pt, RGBColor


ROOT = Path(__file__).resolve().parents[1]
REPORT_DIR = ROOT / "report"
SCREENSHOTS = REPORT_DIR / "screenshots"
DIAGRAMS = REPORT_DIR / "diagrams"
OUTPUT = REPORT_DIR / "Villis_Cafe_Final_Report.docx"
LOGO = ROOT / "assets" / "images" / "villis_cafe_logo.png"

ORANGE = "C63D0A"
BROWN = "5A2A18"
CREAM = "FFF7ED"
LIGHT_ORANGE = "FDE2D1"
INK = "211714"
MUTED = "6F625D"
GREEN = "238650"
RED = "B42318"


def pil_color(value):
    return f"#{value}" if isinstance(value, str) and len(value) == 6 and not value.startswith("#") else value


def font(size, bold=False):
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/Library/Fonts/Arial Bold.ttf" if bold else "/Library/Fonts/Arial.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ]
    for candidate in candidates:
        if Path(candidate).exists():
            return ImageFont.truetype(candidate, size)
    return ImageFont.load_default()


def rounded_box(draw, xy, fill, outline=BROWN, radius=22, width=3):
    draw.rounded_rectangle(xy, radius=radius, fill=pil_color(fill), outline=pil_color(outline), width=width)


def centered_text(draw, xy, text, text_font, fill=INK, spacing=6):
    x1, y1, x2, y2 = xy
    lines = text.split("\n")
    boxes = [draw.textbbox((0, 0), line, font=text_font) for line in lines]
    heights = [box[3] - box[1] for box in boxes]
    total_height = sum(heights) + spacing * (len(lines) - 1)
    y = y1 + (y2 - y1 - total_height) / 2
    for line, box, height in zip(lines, boxes, heights):
        width = box[2] - box[0]
        draw.text((x1 + (x2 - x1 - width) / 2, y), line, font=text_font, fill=pil_color(fill))
        y += height + spacing


def arrow(draw, start, end, fill=BROWN, width=5):
    fill = pil_color(fill)
    draw.line([start, end], fill=fill, width=width)
    x1, y1 = start
    x2, y2 = end
    if abs(x2 - x1) >= abs(y2 - y1):
        direction = 1 if x2 > x1 else -1
        points = [(x2, y2), (x2 - 18 * direction, y2 - 12), (x2 - 18 * direction, y2 + 12)]
    else:
        direction = 1 if y2 > y1 else -1
        points = [(x2, y2), (x2 - 12, y2 - 18 * direction), (x2 + 12, y2 - 18 * direction)]
    draw.polygon(points, fill=fill)


def draw_actor(draw, center, label):
    x, y = center
    draw.ellipse((x - 22, y - 85, x + 22, y - 41), outline=pil_color(BROWN), width=5)
    draw.line((x, y - 41, x, y + 35), fill=pil_color(BROWN), width=5)
    draw.line((x - 50, y - 5, x + 50, y - 5), fill=pil_color(BROWN), width=5)
    draw.line((x, y + 35, x - 45, y + 92), fill=pil_color(BROWN), width=5)
    draw.line((x, y + 35, x + 45, y + 92), fill=pil_color(BROWN), width=5)
    centered_text(draw, (x - 110, y + 105, x + 110, y + 165), label, font(26, True), fill=INK)


def make_use_case_diagram(path):
    image = Image.new("RGB", (1600, 1000), "white")
    draw = ImageDraw.Draw(image)
    draw.rectangle((250, 70, 1350, 920), fill="#FFF9F5", outline="#D8C0B4", width=4)
    centered_text(draw, (250, 82, 1350, 145), "Villi’s Cafe System Boundary", font(32, True), fill=BROWN)
    draw_actor(draw, (115, 420), "Customer")
    draw_actor(draw, (1485, 420), "Administrator")

    customer_cases = [
        (380, 190, 760, 285, "Register / sign in"),
        (380, 330, 760, 425, "Browse and search menu"),
        (380, 470, 760, 565, "Manage cart"),
        (380, 610, 760, 705, "Place simulated order"),
        (380, 750, 760, 845, "View orders, loyalty,\npromotions and chat"),
    ]
    admin_cases = [
        (860, 240, 1240, 335, "Manage products"),
        (860, 430, 1240, 525, "Update order status"),
        (860, 620, 1240, 715, "Reply to customer chat"),
    ]
    for item in customer_cases + admin_cases:
        draw.ellipse(item[:4], fill="#FDE2D1", outline="#C63D0A", width=4)
        centered_text(draw, item[:4], item[4], font(25, True), fill=INK)
    for item in customer_cases:
        draw.line((165, 420, item[0], (item[1] + item[3]) // 2), fill="#7B5B4C", width=3)
    for item in admin_cases:
        draw.line((1435, 420, item[2], (item[1] + item[3]) // 2), fill="#7B5B4C", width=3)
    image.save(path, quality=95)


def make_architecture_diagram(path):
    image = Image.new("RGB", (1600, 900), "white")
    draw = ImageDraw.Draw(image)
    centered_text(draw, (80, 30, 1520, 100), "Layered Architecture and Data Flow", font(38, True), fill=BROWN)
    boxes = [
        ((90, 170, 390, 390), "Presentation\nScreens • widgets\nMaterial 3"),
        ((485, 170, 785, 390), "State\nProvider +\nChangeNotifier"),
        ((880, 170, 1180, 390), "Data access\nRepositories\nValidation boundaries"),
        ((1275, 170, 1575, 390), "Persistence\nSQLite via sqflite\nLocal device"),
    ]
    fills = ["#FFF1E8", "#FDE2D1", "#F7EADB", "#E7F2EA"]
    for (xy, text), fill in zip(boxes, fills):
        rounded_box(draw, xy, fill=fill, outline="#7B5B4C")
        centered_text(draw, xy, text, font(29, True), fill=INK, spacing=12)
    for left, right in zip(boxes, boxes[1:]):
        arrow(draw, (left[0][2] + 12, 280), (right[0][0] - 12, 280), fill=ORANGE)
        arrow(draw, (right[0][0] - 12, 325), (left[0][2] + 12, 325), fill="#7B5B4C")

    rounded_box(draw, (180, 540, 700, 760), fill="#F5F1ED", outline="#7B5B4C")
    centered_text(draw, (180, 540, 700, 760), "Shared domain models\nProduct • CartItem • Order\nAppUser • ChatMessage", font(28, True), fill=INK, spacing=12)
    rounded_box(draw, (900, 540, 1420, 760), fill="#EEF3FA", outline="#4E6580")
    centered_text(draw, (900, 540, 1420, 760), "External image source\nUnsplash HTTPS\nConsumed by presentation\nPlaceholder on failure", font(27, True), fill=INK, spacing=10)
    arrow(draw, (635, 540), (630, 410), fill="#7B5B4C")
    centered_text(draw, (80, 805, 1520, 865), "UI events flowed right; loaded state and error results flowed left.", font(25), fill=MUTED)
    image.save(path, quality=95)


def entity_box(draw, xy, title, fields, fill):
    x1, y1, x2, y2 = xy
    rounded_box(draw, xy, fill=fill, outline="#6D4B3C", radius=14, width=3)
    draw.rectangle((x1, y1, x2, y1 + 52), fill="#6D4B3C")
    centered_text(draw, (x1, y1, x2, y1 + 52), title, font(25, True), fill="white")
    y = y1 + 65
    for field in fields:
        draw.text((x1 + 18, y), field, font=font(20), fill=pil_color(INK))
        y += 31


def make_er_diagram(path):
    image = Image.new("RGB", (1700, 1050), "white")
    draw = ImageDraw.Draw(image)
    centered_text(draw, (80, 20, 1620, 90), "SQLite Entity–Relationship Diagram", font(38, True), fill=BROWN)

    entities = {
        "users": ((70, 160, 490, 455), ["PK id", "name", "phone", "email (unique)", "passwordHash", "role", "createdAt"]),
        "auth_session": ((70, 610, 490, 820), ["PK id (= 1)", "FK userId"]),
        "chat_messages": ((640, 160, 1070, 455), ["PK id", "FK userId", "senderRole", "message", "createdAt"]),
        "products": ((1210, 130, 1630, 455), ["PK id", "name", "description", "category", "price", "image", "rating"]),
        "cart_items": ((1210, 620, 1630, 870), ["PK id", "FK productId (unique)", "quantity"]),
        "orders": ((640, 610, 1070, 945), ["PK id", "customerName", "phone", "address", "total", "paymentMethod", "status", "createdAt"]),
    }
    colors = ["#FFF1E8", "#FDE2D1", "#F7EADB", "#E7F2EA", "#EEF3FA", "#F4EEFA"]
    for (name, (xy, fields)), fill in zip(entities.items(), colors):
        entity_box(draw, xy, name, fields, fill)

    arrow(draw, (280, 610), (280, 470), fill=ORANGE)
    draw.text((305, 515), "one active session", font=font(19, True), fill=pil_color(MUTED))
    arrow(draw, (640, 300), (505, 300), fill=ORANGE)
    draw.text((522, 246), "many → 1", font=font(16, True), fill=pil_color(MUTED))
    arrow(draw, (1420, 620), (1420, 470), fill=ORANGE)
    draw.text((1250, 520), "one cart row per product", font=font(19, True), fill=pil_color(MUTED))
    draw.text((1135, 920), "Orders stored delivery snapshots;\nno card credentials were persisted.", font=font(17, True), fill=pil_color(MUTED))
    image.save(path, quality=95)


def set_cell_shading(cell, fill):
    tc_pr = cell._tc.get_or_add_tcPr()
    shd = tc_pr.find(qn("w:shd"))
    if shd is None:
        shd = OxmlElement("w:shd")
        tc_pr.append(shd)
    shd.set(qn("w:fill"), fill)


def set_cell_margins(cell, top=90, start=110, bottom=90, end=110):
    tc = cell._tc
    tc_pr = tc.get_or_add_tcPr()
    tc_mar = tc_pr.first_child_found_in("w:tcMar")
    if tc_mar is None:
        tc_mar = OxmlElement("w:tcMar")
        tc_pr.append(tc_mar)
    for margin, value in (("top", top), ("start", start), ("bottom", bottom), ("end", end)):
        node = tc_mar.find(qn(f"w:{margin}"))
        if node is None:
            node = OxmlElement(f"w:{margin}")
            tc_mar.append(node)
        node.set(qn("w:w"), str(value))
        node.set(qn("w:type"), "dxa")


def set_repeat_table_header(row):
    tr_pr = row._tr.get_or_add_trPr()
    tbl_header = OxmlElement("w:tblHeader")
    tbl_header.set(qn("w:val"), "true")
    tr_pr.append(tbl_header)


def add_field(paragraph, instruction, placeholder=None):
    run = paragraph.add_run()
    begin = OxmlElement("w:fldChar")
    begin.set(qn("w:fldCharType"), "begin")
    instruction_text = OxmlElement("w:instrText")
    instruction_text.set(qn("xml:space"), "preserve")
    instruction_text.text = instruction
    separate = OxmlElement("w:fldChar")
    separate.set(qn("w:fldCharType"), "separate")
    end = OxmlElement("w:fldChar")
    end.set(qn("w:fldCharType"), "end")
    run._r.extend([begin, instruction_text, separate])
    if placeholder:
        text = OxmlElement("w:t")
        text.text = placeholder
        run._r.append(text)
    run._r.append(end)


def add_page_number(paragraph):
    paragraph.alignment = WD_ALIGN_PARAGRAPH.CENTER
    add_field(paragraph, " PAGE ", "1")


def set_page_number_start(section, value):
    sect_pr = section._sectPr
    pg_num_type = sect_pr.find(qn("w:pgNumType"))
    if pg_num_type is None:
        pg_num_type = OxmlElement("w:pgNumType")
        sect_pr.append(pg_num_type)
    pg_num_type.set(qn("w:start"), str(value))


def add_hyperlink(paragraph, text, url, color=ORANGE, underline=True):
    part = paragraph.part
    relationship_id = part.relate_to(
        url,
        "http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink",
        is_external=True,
    )
    hyperlink = OxmlElement("w:hyperlink")
    hyperlink.set(qn("r:id"), relationship_id)
    new_run = OxmlElement("w:r")
    r_pr = OxmlElement("w:rPr")
    color_el = OxmlElement("w:color")
    color_el.set(qn("w:val"), color)
    r_pr.append(color_el)
    if underline:
        underline_el = OxmlElement("w:u")
        underline_el.set(qn("w:val"), "single")
        r_pr.append(underline_el)
    new_run.append(r_pr)
    text_el = OxmlElement("w:t")
    text_el.text = text
    new_run.append(text_el)
    hyperlink.append(new_run)
    paragraph._p.append(hyperlink)


def add_caption(document, caption):
    p = document.add_paragraph(style="Caption")
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.add_run(caption)
    return p


def add_picture(document, path, caption, width=6.3):
    p = document.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_after = Pt(3)
    p.add_run().add_picture(str(path), width=Inches(width))
    add_caption(document, caption)


def add_two_pictures(document, items):
    table = document.add_table(rows=1, cols=2)
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.autofit = False
    for cell, (path, caption) in zip(table.rows[0].cells, items):
        cell.width = Inches(3.1)
        cell.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.TOP
        p = cell.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.add_run().add_picture(str(path), width=Inches(2.75))
        cp = cell.add_paragraph()
        cp.style = "Caption"
        cp.alignment = WD_ALIGN_PARAGRAPH.CENTER
        cp.add_run(caption)
    document.add_paragraph()


def add_table(document, headers, rows, widths=None, font_size=9):
    table = document.add_table(rows=1, cols=len(headers))
    table.style = "Table Grid"
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    set_repeat_table_header(table.rows[0])
    for index, header in enumerate(headers):
        cell = table.rows[0].cells[index]
        set_cell_shading(cell, BROWN)
        set_cell_margins(cell)
        paragraph = cell.paragraphs[0]
        paragraph.alignment = WD_ALIGN_PARAGRAPH.CENTER
        run = paragraph.add_run(header)
        run.bold = True
        run.font.color.rgb = RGBColor(255, 255, 255)
        run.font.size = Pt(font_size)
    for row_index, row_data in enumerate(rows):
        cells = table.add_row().cells
        for index, value in enumerate(row_data):
            cell = cells[index]
            set_cell_margins(cell)
            if row_index % 2:
                set_cell_shading(cell, "FFF9F5")
            paragraph = cell.paragraphs[0]
            paragraph.paragraph_format.space_after = Pt(0)
            run = paragraph.add_run(str(value))
            run.font.size = Pt(font_size)
    if widths:
        for row in table.rows:
            for index, width in enumerate(widths):
                row.cells[index].width = Inches(width)
    return table


def add_bullet(document, text, level=0):
    style = "List Bullet" if level == 0 else "List Bullet 2"
    p = document.add_paragraph(style=style)
    p.add_run(text)
    return p


def add_number(document, text):
    p = document.add_paragraph(style="List Number")
    p.add_run(text)
    return p


def add_placeholder_box(document, title, text):
    table = document.add_table(rows=1, cols=1)
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    cell = table.cell(0, 0)
    set_cell_shading(cell, "FFF1CC")
    set_cell_margins(cell, top=160, start=180, bottom=160, end=180)
    p = cell.paragraphs[0]
    run = p.add_run(title + "\n")
    run.bold = True
    run.font.color.rgb = RGBColor.from_string(RED)
    p.add_run(text)
    document.add_paragraph()


def configure_document(document):
    styles = document.styles
    normal = styles["Normal"]
    normal.font.name = "Aptos"
    normal.font.size = Pt(10.5)
    normal.font.color.rgb = RGBColor.from_string(INK)
    normal.paragraph_format.line_spacing = 1.15
    normal.paragraph_format.space_after = Pt(7)
    normal.paragraph_format.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY

    for name, size, color in (("Title", 28, BROWN), ("Heading 1", 19, BROWN), ("Heading 2", 14, ORANGE), ("Heading 3", 11.5, BROWN)):
        style = styles[name]
        style.font.name = "Aptos Display"
        style.font.size = Pt(size)
        style.font.bold = True
        style.font.color.rgb = RGBColor.from_string(color)
        style.paragraph_format.keep_with_next = True
        style.paragraph_format.space_before = Pt(12)
        style.paragraph_format.space_after = Pt(6)
    styles["Caption"].font.name = "Aptos"
    styles["Caption"].font.size = Pt(9)
    styles["Caption"].font.italic = True
    styles["Caption"].font.color.rgb = RGBColor.from_string(MUTED)

    section = document.sections[0]
    section.page_width = Cm(21)
    section.page_height = Cm(29.7)
    section.top_margin = Cm(2)
    section.bottom_margin = Cm(2)
    section.left_margin = Cm(2.2)
    section.right_margin = Cm(2.2)


def build_report():
    DIAGRAMS.mkdir(parents=True, exist_ok=True)
    make_use_case_diagram(DIAGRAMS / "use_case_diagram.png")
    make_architecture_diagram(DIAGRAMS / "high_level_architecture.png")
    make_er_diagram(DIAGRAMS / "er_diagram.png")

    document = Document()
    configure_document(document)
    document.core_properties.title = "Villi’s Cafe Android Mobile Application – Final Report"
    document.core_properties.author = "Samsudeen Ashad (verify before submission)"
    document.core_properties.subject = "PUSL2023 Mobile Application Development"
    document.core_properties.keywords = "Flutter, Dart, SQLite, Provider, Material 3, mobile application"

    # Coursework cover sheet reconstructed from the supplied template.
    p = document.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = p.add_run("COURSEWORK FRONT COVER SHEET")
    run.bold = True
    run.font.size = Pt(19)
    run.font.color.rgb = RGBColor.from_string(BROWN)
    document.add_paragraph()
    cover_rows = [
        ("Name", "Samsudeen Ashad — VERIFY BEFORE SUBMISSION"),
        ("Student Reference Number", "[ENTER STUDENT REFERENCE NUMBER]"),
        ("Module Code", "PUSL2023"),
        ("Module Name", "Mobile Application Development"),
        ("Coursework Title", "Villi’s Cafe Android Mobile Application – Final Report"),
        ("Deadline Date", "[ENTER DEADLINE DATE]"),
        ("Member of staff responsible", "[ENTER MEMBER OF STAFF]"),
        ("Programme", "[ENTER PROGRAMME]"),
    ]
    table = document.add_table(rows=0, cols=2)
    table.style = "Table Grid"
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    for left, right in cover_rows:
        cells = table.add_row().cells
        set_cell_shading(cells[0], LIGHT_ORANGE)
        set_cell_margins(cells[0], top=120, bottom=120)
        set_cell_margins(cells[1], top=120, bottom=120)
        cells[0].paragraphs[0].add_run(left).bold = True
        cells[1].paragraphs[0].add_run(right)

    document.add_paragraph()
    p = document.add_paragraph()
    p.add_run("Group work declaration and participants\n").bold = True
    p.add_run("Repository evidence identified Samsudeen Ashad as the contributor. Add any other formally associated participants here before submission: [ENTER NAMES OR STATE ‘UNDERTAKEN ALONE’].")
    p = document.add_paragraph()
    p.add_run("Assessment offence declaration\n").bold = True
    p.add_run("The submitter confirms that the Plymouth University regulations relating to assessment offences have been read and understood, and that this submission represents the group’s independent work.")
    p = document.add_paragraph()
    p.add_run("Signed on behalf of the group / individual: ").bold = True
    p.add_run("[SIGN BEFORE SUBMISSION]")
    p = document.add_paragraph()
    p.add_run("Use of translation software or a similar writing aid: ").bold = True
    p.add_run("USED — OpenAI Codex assisted with report drafting and formatting. Technical statements were checked against the project source, emulator run, Git history, and automated validation.")

    document.add_page_break()

    # Title page.
    if LOGO.exists():
        p = document.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.add_run().add_picture(str(LOGO), width=Inches(1.8))
    p = document.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(28)
    run = p.add_run("VILLI’S CAFE")
    run.bold = True
    run.font.size = Pt(32)
    run.font.color.rgb = RGBColor.from_string(BROWN)
    p = document.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = p.add_run("Android Mobile Ordering Application")
    run.bold = True
    run.font.size = Pt(20)
    run.font.color.rgb = RGBColor.from_string(ORANGE)
    p = document.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(24)
    p.add_run("Final Project Report\n").bold = True
    p.add_run("PUSL2023 Mobile Application Development\nPlymouth Batch 13 • 2024/2025 Academic Year")
    p = document.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(34)
    p.add_run("Prepared by: Samsudeen Ashad (verify)\n")
    p.add_run("Student Reference Number: [ENTER NUMBER]\n")
    p.add_run("Submission date: [ENTER DATE]")
    p = document.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(46)
    run = p.add_run("Warm bites, made personal.")
    run.italic = True
    run.font.color.rgb = RGBColor.from_string(MUTED)

    # Page-numbered report section starts after the title page.
    section = document.add_section(WD_SECTION.NEW_PAGE)
    section.page_width = Cm(21)
    section.page_height = Cm(29.7)
    section.top_margin = Cm(2)
    section.bottom_margin = Cm(2)
    section.left_margin = Cm(2.2)
    section.right_margin = Cm(2.2)
    section.footer.is_linked_to_previous = False
    set_page_number_start(section, 1)
    add_page_number(section.footer.paragraphs[0])

    document.add_heading("Table of Contents", level=1)
    p = document.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.LEFT
    add_field(p, ' TOC \\o "1-3" \\h \\z \\u ', "Right-click and select Update Field in Microsoft Word if page numbers are not shown.")

    document.add_page_break()
    document.add_heading("List of Figures and Tables", level=1)
    figures = [
        "Figure 3.1 Use case diagram",
        "Figure 3.2 High-level architecture and data flow",
        "Figure 3.3 SQLite entity–relationship diagram",
        "Figure 3.4 Customer home interface",
        "Figure 3.5 Menu and product-details interfaces",
        "Figure 3.6 Checkout and order-summary interfaces",
        "Figure 3.7 Order confirmation and loyalty profile",
        "Figure 3.8 Administrator product-management interface",
    ]
    for item in figures:
        add_bullet(document, item)
    tables = [
        "Table 2.1 Requirement-gathering evidence",
        "Table 2.2 Functional requirements",
        "Table 2.3 Non-functional requirements",
        "Table 4.1 Technologies and tools",
        "Table 4.2 Verification results",
        "Table 5.1 Git contribution summary",
        "Table A.1 Complete Git commit history",
    ]
    for item in tables:
        add_bullet(document, item)

    document.add_page_break()
    document.add_heading("Chapter 01 – Introduction", level=1)
    document.add_heading("1.1 Project background", level=2)
    document.add_paragraph(
        "Villi’s Cafe was developed as a compact Android ordering application for a local café. The project responded to a familiar service problem: customers often needed to inspect a menu, compare items, and prepare an order before reaching a counter. A mobile interface reduced that friction by placing browsing, cart calculation, checkout, promotions, order tracking, loyalty information, notifications, and café messaging in one flow. The implementation remained intentionally local and understandable because it was produced for undergraduate mobile application development."
    )
    document.add_paragraph(
        "The completed product was implemented with Flutter and Dart. Material 3 supplied the visual foundation, Provider coordinated observable application state, and SQLite stored accounts, sessions, products, cart entries, orders, and chat messages on the Android device. Product photographs were requested from Unsplash over HTTPS, while a branded placeholder protected the layout when a network image could not be loaded. No remote application server or payment gateway was introduced."
    )

    document.add_heading("1.2 Existing systems and problem definition", level=2)
    document.add_paragraph(
        "Large commercial delivery platforms already support searchable catalogues, card payments, courier tracking, and cloud accounts. However, those systems normally require business onboarding, service fees, continuous network access, and infrastructure that would have exceeded this project’s scope. A small café still benefited from the core interaction pattern, but it did not require a marketplace or a complex backend for a coursework demonstration."
    )
    document.add_paragraph(
        "The problem was therefore defined as the absence of a small, café-specific Android experience that could demonstrate the complete ordering journey without processing real money or exposing personal data to a server. The proposed application had to remain approachable for a student developer while still showing reliable state changes, persistence, validation, responsive layouts, and meaningful recovery states."
    )

    document.add_heading("1.3 Aim and objectives", level=2)
    document.add_paragraph(
        "The project aimed to design and implement a clear, attractive, and locally persistent Android application through which Villi’s Cafe customers could discover products and complete a simulated order."
    )
    objectives = [
        "To present a branded splash, authentication entry, home experience, searchable catalogue, categories, promotions, and reusable product cards.",
        "To provide product details, quantity selection, a persistent cart, and trustworthy subtotal, delivery-charge, and total calculations.",
        "To validate delivery and simulated payment information before saving an order and clearing the cart atomically.",
        "To retain order history, calculate loyalty points, and support customer notifications and two-way local café chat.",
        "To provide an administrator interface for product maintenance, order status management, and chat replies.",
        "To verify behaviour through static analysis, automated unit/widget tests, and execution on an Android emulator.",
    ]
    for objective in objectives:
        add_bullet(document, objective)

    document.add_heading("1.4 Scope of the project", level=2)
    document.add_paragraph(
        "The scope included Android execution, local account registration and sign-in, four menu categories, eight seeded products, text search, product details, cart persistence, three simulated payment choices, order confirmation, order history, promotions, loyalty points, theme switching, notifications, customer–administrator chat, and administrator maintenance. Loading, empty, error, retry, accessibility, and responsive states were also implemented."
    )
    document.add_paragraph(
        "Real payment processing, live stock control, delivery routing, cloud synchronisation, production-grade identity management, push notification services, and promotion redemption were excluded. Card values were validated only inside the checkout form and were neither transmitted nor written to SQLite. Product and promotion information remained demonstration data."
    )

    document.add_page_break()
    document.add_heading("Chapter 02 – Requirements and Features", level=1)
    document.add_heading("2.1 Requirement-gathering techniques", level=2)
    document.add_paragraph(
        "Requirements were derived through document analysis, scenario decomposition, lightweight competitor observation, and iterative prototype review. The original café brief was translated into user journeys and acceptance checks. The repository’s phase checklist then divided the work into foundation, browsing, cart, checkout, history, and quality stages. Later commits extended the product with local authentication, messaging, notifications, an administrator role, and dark mode."
    )
    add_table(
        document,
        ["Technique", "Evidence used", "Outcome"],
        [
            ("Brief analysis", "Original assignment retained in README", "Identified core screens, categories, payment simulation, persistence, and Android target."),
            ("Scenario and task analysis", "Browse → detail → cart → checkout → confirmation", "Established the primary customer journey and validation points."),
            ("Prototype review", "Responsive layouts and real emulator execution", "Refined hierarchy, touch targets, error states, and navigation."),
            ("Repository review", "Source, tests, README, task checklist, and Git history", "Confirmed implemented behaviour and prevented unsupported claims."),
        ],
        widths=[1.25, 2.25, 3.15],
        font_size=8.5,
    )
    add_caption(document, "Table 2.1 Requirement-gathering evidence")

    document.add_heading("2.2 Functional requirements", level=2)
    functional_rows = [
        ("FR1", "The system shall register local customers, restore a saved session, sign users in, and separate customer and administrator roles.", "Implemented"),
        ("FR2", "Customers shall browse, search, and filter products by Burgers, Pizza, Drinks, and Desserts.", "Implemented"),
        ("FR3", "Customers shall inspect product details, select quantity, and add, adjust, or remove persistent cart items.", "Implemented"),
        ("FR4", "The checkout shall validate delivery details and the selected simulated payment method before submission.", "Implemented"),
        ("FR5", "The system shall calculate totals, save an order, clear the cart in one transaction, and show confirmation/history.", "Implemented"),
        ("FR6", "Customers shall view promotions, loyalty points, notifications, profile details, and café chat.", "Implemented"),
        ("FR7", "Administrators shall manage products, change order status, and reply to customer conversations.", "Implemented"),
    ]
    add_table(document, ["ID", "Requirement", "Status"], functional_rows, widths=[0.55, 5.35, 0.9], font_size=8.5)
    add_caption(document, "Table 2.2 Functional requirements")

    document.add_heading("2.3 Non-functional requirements", level=2)
    non_functional_rows = [
        ("NFR1 Usability", "The five customer destinations and three administrator destinations shall use clear labels, consistent actions, and restrained visual hierarchy."),
        ("NFR2 Reliability", "Committed cart and order changes shall not be repeated when a later refresh fails; order creation and cart clearing shall be atomic."),
        ("NFR3 Privacy", "Accounts and sessions shall remain local. Payment shall be identified as simulated, and card fields shall not be persisted."),
        ("NFR4 Accessibility", "Semantic labels, large touch targets, readable contrast, reduced-motion awareness, and large-text layouts shall be supported."),
        ("NFR5 Responsiveness", "Screens shall adapt across narrow phones, landscape layouts, and wider grids without hiding essential actions."),
        ("NFR6 Maintainability", "Models, providers, repositories, services, screens, widgets, utilities, and tests shall remain separated by responsibility."),
        ("NFR7 Compatibility", "The deliverable shall build and execute on Android using the configured Flutter and Gradle toolchains."),
    ]
    add_table(document, ["Requirement", "Acceptance interpretation"], non_functional_rows, widths=[1.35, 5.45], font_size=8.5)
    add_caption(document, "Table 2.3 Non-functional requirements")

    document.add_heading("2.4 Features of the application", level=2)
    document.add_paragraph(
        "The final application offered more than a catalogue. A two-second branded splash led to local authentication. The customer shell exposed Home, Menu, Cart, Orders, and Profile tabs, with notification and chat entry points. Search and category filters reused the same product state, while product cards and detail views shared cart operations. The checkout supported Cash on Delivery, Credit/Debit Card, and Digital Wallet demonstrations. Card numbers were checked with the Luhn algorithm, expiry dates were compared with the current month, and CVV input was constrained to three or four digits."
    )
    document.add_paragraph(
        "The administrator shell separated product, order, and conversation work. Product records could be added, edited, or deleted. Order statuses could be changed among preparing, confirmed, rejected, and delivered states. Customer messages were grouped for administrator replies. Across both roles, Provider exposed loading and error state without placing SQL inside widgets."
    )

    document.add_page_break()
    document.add_heading("Chapter 03 – System Design and User Interface", level=1)
    document.add_heading("3.1 Use case diagram", level=2)
    document.add_paragraph(
        "Two actors were supported. Customers controlled their account, discovery, ordering, history, loyalty, and communication journeys. Administrators maintained operational data and replied to conversations. The system boundary in Figure 3.1 shows the intentional separation between these responsibilities."
    )
    add_picture(document, DIAGRAMS / "use_case_diagram.png", "Figure 3.1 Use case diagram", width=6.45)

    document.add_heading("3.2 High-level architecture", level=2)
    document.add_paragraph(
        "A layered architecture was selected so that each state change could be traced from a widget to local storage. Screens and reusable widgets initiated events. ChangeNotifier providers coordinated UI state and error reporting. Repositories implemented database operations, and DatabaseService created or upgraded the SQLite schema. Typed models crossed the boundaries. The arrangement reduced coupling and allowed providers and screens to be tested with repository stubs."
    )
    add_picture(document, DIAGRAMS / "high_level_architecture.png", "Figure 3.2 High-level architecture and data flow", width=6.45)

    document.add_heading("3.3 Entity–relationship design", level=2)
    document.add_paragraph(
        "SQLite version 4 contained six tables. Products were seeded during database creation. Cart entries referenced products and enforced one row per product. Sessions referenced users and restricted the active-session identifier to one. Chat messages referenced their customer. Orders retained a delivery snapshot rather than a user foreign key, which kept the order record self-contained. Payment credentials were deliberately absent from the schema."
    )
    add_picture(document, DIAGRAMS / "er_diagram.png", "Figure 3.3 SQLite entity–relationship diagram", width=6.45)

    document.add_heading("3.4 User interface of the developed system", level=2)
    document.add_paragraph(
        "The interface used a warm cream background, orange actions, dark brown typography, rounded cards, and the café mark. The Android emulator captures below were recorded from the running debug application on 25 August 2026. They show the most important points in the customer and administrator journeys rather than every screen."
    )
    add_picture(document, SCREENSHOTS / "09_customer_home.png", "Figure 3.4 Customer home interface with promotion carousel and category navigation", width=3.25)
    add_two_pictures(
        document,
        [
            (SCREENSHOTS / "10_menu.png", "Figure 3.5(a) Searchable and filterable menu"),
            (SCREENSHOTS / "11_product_details.png", "Figure 3.5(b) Product detail and quantity selection"),
        ],
    )
    add_two_pictures(
        document,
        [
            (SCREENSHOTS / "13_checkout.png", "Figure 3.6(a) Delivery and payment selection"),
            (SCREENSHOTS / "14_checkout_summary.png", "Figure 3.6(b) Simulated checkout summary"),
        ],
    )
    add_two_pictures(
        document,
        [
            (SCREENSHOTS / "15_order_confirmation.png", "Figure 3.7(a) Saved order confirmation"),
            (SCREENSHOTS / "16_profile_loyalty.png", "Figure 3.7(b) Local profile and loyalty points"),
        ],
    )
    add_picture(document, SCREENSHOTS / "08_admin_dashboard.png", "Figure 3.8 Administrator product-management interface", width=3.25)

    document.add_page_break()
    document.add_heading("Chapter 04 – Development and Evaluation", level=1)
    document.add_heading("4.1 Development methodology", level=2)
    document.add_paragraph(
        "An iterative, feature-based methodology was followed. The foundation introduced the Flutter project, theme, models, SQLite service, repositories, and providers. Product browsing and responsive cards were completed next. Persistent cart behaviour was then added before checkout and order confirmation. History, profile, promotions, and loyalty followed. The quality pass addressed accessibility, responsive behaviour, empty/error states, tests, documentation, authentication, chat, notifications, administrator controls, and dark mode."
    )
    document.add_paragraph(
        "This order reduced risk because later screens reused stable models and repository operations. Commits remained small enough to show the development sequence. When resilience tests exposed the possibility of retrying an already committed change, providers were hardened so that refresh failures produced a message without duplicating database mutations."
    )

    document.add_heading("4.2 Technologies and tools used", level=2)
    technology_rows = [
        ("Flutter 3.47.1 / Dart 3.13.1", "Cross-platform UI toolkit and language used for the Android application."),
        ("Material 3", "Theme, navigation, controls, forms, cards, colour schemes, and accessible interaction patterns."),
        ("Provider 6.1.5+1", "ChangeNotifier-based state delivery for authentication, navigation, theme, products, cart, orders, and chat."),
        ("sqflite 2.4.2 + SQLite", "Embedded relational persistence, constraints, indexes, migrations, and transactions."),
        ("crypto 3.0.7", "SHA-256 hashing for local demonstration passwords."),
        ("Android SDK 36 / emulator", "Android 16 runtime used for build installation, interaction, and screenshot evidence."),
        ("Flutter test and analyzer", "Unit, widget, responsive, navigation, validation, and resilience verification."),
        ("Git and GitHub", "Version history and remote source publication."),
    ]
    add_table(document, ["Technology/tool", "Use in the project"], technology_rows, widths=[2.05, 4.75], font_size=8.5)
    add_caption(document, "Table 4.1 Technologies and tools")

    document.add_heading("4.3 Testing and evaluation", level=2)
    document.add_paragraph(
        "Evaluation combined code inspection, automated validation, and a complete Android walkthrough. Tests covered model mapping, currency and validators, Material theming, splash timing, five-tab navigation, cart and checkout protection, promotions, order history, profile loyalty, chat, administrator functionality, provider recovery, and narrow/landscape/large-text layouts. The emulator journey registered a customer, added a product, placed a Cash on Delivery order, observed confirmation, and reviewed loyalty state."
    )
    verification_rows = [
        ("Android debug build", "Passed", "build/app/outputs/flutter-apk/app-debug.apk was produced and installed."),
        ("Runtime walkthrough", "Passed", "Application launched on Pixel 7 Android 16 emulator and completed the core customer flow."),
        ("flutter analyze", "Passed", "No issues found on 25 August 2026."),
        ("flutter test", "Passed", "42 tests passed on 25 August 2026."),
        ("Privacy inspection", "Passed", "Cardholder, card number, expiry, and CVV fields were not present in the SQLite orders schema."),
    ]
    add_table(document, ["Check", "Result", "Evidence"], verification_rows, widths=[1.45, 0.8, 4.55], font_size=8.5)
    add_caption(document, "Table 4.2 Verification results")
    document.add_paragraph(
        "The evaluation demonstrated a coherent coursework application rather than a production ordering service. One limitation of the local design was that café data did not synchronise between devices. Network product imagery could also vary with connectivity, although placeholders protected usability. The application made this boundary clear by labelling payments as simulated and keeping account data on the device."
    )

    document.add_heading("4.4 Future implementation", level=2)
    future_items = [
        "Introduce a secured cloud API and managed identity service so that products, orders, chat, and accounts can synchronise across devices.",
        "Integrate a compliant payment provider using tokenisation; sensitive card data should remain outside the application and its database.",
        "Add real inventory, configurable café opening hours, promotion redemption, tax rules, receipts, and order cancellation policies.",
        "Connect push notifications to server-side order status changes and extend administrator access controls and audit logs.",
        "Run usability sessions with café staff and customers, then add integration, database migration, performance, and physical-device test coverage.",
    ]
    for item in future_items:
        add_bullet(document, item)

    document.add_page_break()
    document.add_heading("Chapter 05 – Contribution and Source Control", level=1)
    document.add_heading("5.1 Individual contribution", level=2)
    document.add_paragraph(
        "The repository contained 23 commits attributed to Samsudeen Ashad through two equivalent Git identities. The history covered the project scaffold, core architecture, product discovery, cart, checkout, confirmation, promotions, profile, loyalty, authentication, administrator controls, chat, notifications, dark mode, Android configuration, testing, resilience, documentation, and the final Villi’s Cafe rebrand. On the evidence available in the repository, this represented the individual contribution to the submitted product."
    )
    add_placeholder_box(
        document,
        "Contribution details to verify",
        "If this was group work, add one short, accurate paragraph for every additional member and adjust the cover declaration. Do not submit the single-contributor statement unless it is correct.",
    )
    contribution_rows = [
        ("Samsudeen Ashad", "23", "Application architecture, UI, SQLite persistence, customer/admin features, automated tests, Android configuration, documentation, and rebranding."),
    ]
    add_table(document, ["Contributor", "Commits", "Repository-evidenced work"], contribution_rows, widths=[1.5, 0.7, 4.6], font_size=8.5)
    add_caption(document, "Table 5.1 Git contribution summary")

    document.add_heading("5.2 GitHub repository and commit history", level=2)
    p = document.add_paragraph()
    p.add_run("GitHub repository: ").bold = True
    add_hyperlink(p, "https://github.com/SamsudeenAshad/QuickBite-Cafe", "https://github.com/SamsudeenAshad/QuickBite-Cafe")
    document.add_paragraph(
        "The full commit history is reproduced in Appendix A. The sequence showed an incremental implementation rather than a single bulk upload, with feature and corrective commits describing the behaviour introduced at each stage."
    )

    document.add_heading("5.3 Project source code link", level=2)
    add_placeholder_box(
        document,
        "MANDATORY BEFORE SUBMISSION — PLYMOUTH ONEDRIVE SOURCE LINK",
        "Paste the public/evaluator-accessible Plymouth OneDrive source-code URL here: [PASTE ONEDRIVE LINK]. The supplied guideline states that omission or inaccessible permissions will result in zero marks.",
    )

    document.add_page_break()
    document.add_heading("Reference List", level=1)
    references = [
        ("Flutter", "2026", "Material Design for Flutter", "https://docs.flutter.dev/ui/design/material"),
        ("Flutter", "2026", "General approach to adaptive apps", "https://docs.flutter.dev/ui/adaptive-responsive/general"),
        ("Remi Rousselet and contributors", "2025", "provider 6.1.5+1", "https://pub.dev/packages/provider"),
        ("Tekartik", "2026", "sqflite: SQLite plugin for Flutter", "https://pub.dev/packages/sqflite"),
        ("SQLite Project", "2026", "Transaction", "https://www.sqlite.org/lang_transaction.html"),
        ("Villi’s Cafe project repository", "2026", "QuickBite-Cafe source code and README", "https://github.com/SamsudeenAshad/QuickBite-Cafe"),
    ]
    for author, year, title, url in references:
        p = document.add_paragraph()
        p.paragraph_format.left_indent = Cm(0.7)
        p.paragraph_format.first_line_indent = Cm(-0.7)
        p.add_run(f"{author} ({year}) {title}. Available at: ")
        add_hyperlink(p, url, url)
        p.add_run(" (Accessed: 25 August 2026).")

    document.add_page_break()
    document.add_heading("Appendix A – Complete Git Commit History", level=1)
    commits = [
        ("2d37f20", "2026-08-23", "Initial commit"),
        ("4b2f381", "2026-08-23", "Update README.md"),
        ("49cbe2e", "2026-08-24", "Update README.md"),
        ("470d61c", "2026-08-24", "Implement core functionality for QuickBite Café app"),
        ("f1aa2aa", "2026-08-24", "Refactor cart and order providers; update Gradle configuration and add unit tests"),
        ("39394cc", "2026-08-24", "Add splash, catalogue, and product browsing"),
        ("a34eeb7", "2026-08-24", "Add profile and promotions screens with associated UI components"),
        ("e309fe3", "2026-08-24", "Streamline SnackBar and MaterialApp widget formatting"),
        ("8c48546", "2026-08-24", "Add persistent shopping cart"),
        ("dff8bf4", "2026-08-24", "Connect checkout and order confirmation"),
        ("3332576", "2026-08-24", "Complete orders, promotions, and loyalty"),
        ("228f863", "2026-08-24", "Update README and add responsive layout tests"),
        ("988ad50", "2026-08-24", "Harden cart and order recovery"),
        ("b65cedf", "2026-08-24", "Configure Flutter Android NDK"),
        ("7474b1e", "2026-08-24", "Improve menu category visibility"),
        ("6ab618a", "2026-08-24", "Add local account authentication"),
        ("ab1cdbd", "2026-08-24", "Add food promotion carousel"),
        ("06ef53c", "2026-08-24", "Add café chat and administrator management"),
        ("3f1cff9", "2026-08-24", "Connect customer chat to administrator replies"),
        ("215297e", "2026-08-24", "Add customer notification panel"),
        ("ec61ab5", "2026-08-24", "Add accessible dark mode"),
        ("e5d6e10", "2026-08-24", "Improve dark mode icon contrast"),
        ("0b97f5f", "2026-08-24", "Rebrand application as Villi’s Cafe"),
    ]
    add_table(document, ["Commit", "Date", "Message"], commits, widths=[0.9, 1.15, 4.75], font_size=8)
    add_caption(document, "Table A.1 Complete Git commit history from the main branch")

    document.add_heading("Appendix B – Validation and Screenshot Evidence", level=1)
    document.add_paragraph(
        "Validation was executed from the project root on 25 August 2026. Flutter built and installed the debug APK on emulator-5554 (Pixel 7, Android 16/API 36). Static analysis completed with no issues, and the test suite completed with 42 passing tests. The selected PNG captures in the report/screenshots folder were obtained with Android Debug Bridge from that running application."
    )
    evidence = [
        "08_admin_dashboard.png — administrator product maintenance",
        "09_customer_home.png — home, promotions, search, and categories",
        "10_menu.png — product catalogue and filters",
        "11_product_details.png — product details and cart action",
        "13_checkout.png — delivery and simulated payment form",
        "14_checkout_summary.png — totals and place-order action",
        "15_order_confirmation.png — persisted order confirmation QB1002",
        "16_profile_loyalty.png — customer profile and loyalty state",
    ]
    for item in evidence:
        add_bullet(document, item)

    # Ask Word to update TOC and fields on open.
    settings = document.settings.element
    update_fields = settings.find(qn("w:updateFields"))
    if update_fields is None:
        update_fields = OxmlElement("w:updateFields")
        settings.append(update_fields)
    update_fields.set(qn("w:val"), "true")

    document.save(OUTPUT)
    return OUTPUT


if __name__ == "__main__":
    output = build_report()
    print(output)
