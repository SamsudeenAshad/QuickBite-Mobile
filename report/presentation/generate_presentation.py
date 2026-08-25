from datetime import datetime
from pathlib import Path

from PIL import Image
from pptx import Presentation
from pptx.dml.color import RGBColor
from pptx.enum.shapes import MSO_AUTO_SHAPE_TYPE
from pptx.enum.text import MSO_ANCHOR, PP_ALIGN
from pptx.oxml.xmlchemy import OxmlElement
from pptx.util import Inches, Pt


ROOT = Path(__file__).resolve().parents[2]
REPORT = ROOT / "report"
PRESENTATION_DIR = REPORT / "presentation"
OUTPUT = PRESENTATION_DIR / "Villis_Cafe_Project_Demonstration.pptx"
LOGO = ROOT / "assets" / "images" / "villis_cafe_logo.png"
SCREENSHOTS = REPORT / "screenshots"
DIAGRAMS = REPORT / "diagrams"

SLIDE_W = 13.333
SLIDE_H = 7.5

CREAM = "FFF8F1"
PAPER = "FFFCF8"
ORANGE = "CC3D05"
ORANGE_2 = "F16A21"
PEACH = "FCE1D0"
BROWN = "542819"
INK = "201714"
MUTED = "71635D"
LINE = "E7D2C5"
GREEN = "218653"
GREEN_BG = "E4F1E9"
RED = "B42318"
BLUE = "2E628D"
BLUE_BG = "E8F0F7"
WHITE = "FFFFFF"


def rgb(hex_value):
    return RGBColor.from_string(hex_value)


def add_rect(slide, x, y, w, h, fill=PAPER, line=LINE, radius=True, line_width=1):
    shape_type = MSO_AUTO_SHAPE_TYPE.ROUNDED_RECTANGLE if radius else MSO_AUTO_SHAPE_TYPE.RECTANGLE
    shape = slide.shapes.add_shape(shape_type, Inches(x), Inches(y), Inches(w), Inches(h))
    shape.fill.solid()
    shape.fill.fore_color.rgb = rgb(fill)
    shape.line.color.rgb = rgb(line)
    shape.line.width = Pt(line_width)
    if radius:
        try:
            shape.adjustments[0] = 0.12
        except Exception:
            pass
    return shape


def add_text(
    slide,
    text,
    x,
    y,
    w,
    h,
    size=20,
    color=INK,
    bold=False,
    font="Aptos",
    align=PP_ALIGN.LEFT,
    valign=MSO_ANCHOR.TOP,
    margin=0,
    line_spacing=1.0,
):
    box = slide.shapes.add_textbox(Inches(x), Inches(y), Inches(w), Inches(h))
    frame = box.text_frame
    frame.clear()
    frame.margin_left = Inches(margin)
    frame.margin_right = Inches(margin)
    frame.margin_top = Inches(margin)
    frame.margin_bottom = Inches(margin)
    frame.vertical_anchor = valign
    frame.word_wrap = True
    paragraph = frame.paragraphs[0]
    paragraph.alignment = align
    paragraph.line_spacing = line_spacing
    run = paragraph.add_run()
    run.text = text
    run.font.name = font
    run.font.size = Pt(size)
    run.font.bold = bold
    run.font.color.rgb = rgb(color)
    return box


def add_rich_lines(slide, lines, x, y, w, h, size=20, color=INK, bullet=False, gap=7, icon_color=ORANGE):
    box = slide.shapes.add_textbox(Inches(x), Inches(y), Inches(w), Inches(h))
    frame = box.text_frame
    frame.clear()
    frame.word_wrap = True
    frame.margin_left = 0
    frame.margin_right = 0
    frame.margin_top = 0
    frame.margin_bottom = 0
    for index, line in enumerate(lines):
        paragraph = frame.paragraphs[0] if index == 0 else frame.add_paragraph()
        paragraph.space_after = Pt(gap)
        paragraph.line_spacing = 1.05
        if bullet:
            marker = paragraph.add_run()
            marker.text = "●  "
            marker.font.name = "Aptos"
            marker.font.size = Pt(max(8, size - 6))
            marker.font.color.rgb = rgb(icon_color)
        if isinstance(line, tuple):
            heading, body = line
            first = paragraph.add_run()
            first.text = heading
            first.font.name = "Aptos"
            first.font.size = Pt(size)
            first.font.bold = True
            first.font.color.rgb = rgb(color)
            second = paragraph.add_run()
            second.text = body
            second.font.name = "Aptos"
            second.font.size = Pt(size)
            second.font.color.rgb = rgb(color)
        else:
            run = paragraph.add_run()
            run.text = line
            run.font.name = "Aptos"
            run.font.size = Pt(size)
            run.font.color.rgb = rgb(color)
    return box


def add_image_contain(slide, path, x, y, w, h):
    with Image.open(path) as image:
        image_w, image_h = image.size
    scale = min(w / image_w, h / image_h)
    placed_w = image_w * scale
    placed_h = image_h * scale
    left = x + (w - placed_w) / 2
    top = y + (h - placed_h) / 2
    return slide.shapes.add_picture(
        str(path), Inches(left), Inches(top), Inches(placed_w), Inches(placed_h)
    )


def add_image_cover(slide, path, x, y, w, h):
    with Image.open(path) as image:
        image_w, image_h = image.size
    target_ratio = w / h
    image_ratio = image_w / image_h
    picture = slide.shapes.add_picture(str(path), Inches(x), Inches(y), width=Inches(w))
    if image_ratio > target_ratio:
        picture.height = Inches(h)
        picture.width = Inches(h * image_ratio)
        picture.left = Inches(x - (h * image_ratio - w) / 2)
        picture.top = Inches(y)
    else:
        picture.width = Inches(w)
        picture.height = Inches(w / image_ratio)
        picture.left = Inches(x)
        picture.top = Inches(y - (w / image_ratio - h) / 2)
    return picture


def crop_picture_to_frame(picture, frame_x, frame_y, frame_w, frame_h):
    # Add a slide clipping mask around an already-covering image.
    slide = picture.part.package.presentation_part.presentation.slides
    return picture


def add_phone(slide, screenshot, x, y, h, label=None):
    w = h * 1080 / 2400
    add_rect(slide, x - 0.09, y - 0.09, w + 0.18, h + 0.18, fill=INK, line=INK, radius=True, line_width=0.5)
    add_image_contain(slide, screenshot, x, y, w, h)
    if label:
        add_text(slide, label, x - 0.05, y + h + 0.11, w + 0.1, 0.3, size=9, color=MUTED, bold=True, align=PP_ALIGN.CENTER)
    return w


def add_title(slide, title, kicker=None, subtitle=None):
    if kicker:
        add_text(slide, kicker.upper(), 0.72, 0.44, 5.0, 0.32, size=10, color=ORANGE, bold=True)
    add_text(slide, title, 0.72, 0.82 if kicker else 0.48, 11.9, 0.68, size=27, color=BROWN, bold=True, font="Aptos Display")
    if subtitle:
        add_text(slide, subtitle, 0.74, 1.48, 11.2, 0.38, size=12, color=MUTED)
    line = slide.shapes.add_shape(MSO_AUTO_SHAPE_TYPE.RECTANGLE, Inches(0.74), Inches(1.92), Inches(11.85), Inches(0.025))
    line.fill.solid()
    line.fill.fore_color.rgb = rgb(LINE)
    line.line.fill.background()


def add_footer(slide, number, section="PROJECT DEMONSTRATION"):
    add_text(slide, f"PUSL2023  •  VILLI’S CAFE  •  {section}", 0.72, 7.13, 6.9, 0.2, size=8, color=MUTED, bold=True)
    add_text(slide, f"{number:02d}", 12.1, 7.08, 0.5, 0.25, size=9, color=ORANGE, bold=True, align=PP_ALIGN.RIGHT)


def add_pill(slide, text, x, y, w, fill=PEACH, color=ORANGE, size=10):
    shape = add_rect(slide, x, y, w, 0.36, fill=fill, line=fill, radius=True, line_width=0)
    add_text(slide, text.upper(), x + 0.06, y + 0.03, w - 0.12, 0.22, size=size, color=color, bold=True, align=PP_ALIGN.CENTER)
    return shape


def add_number_card(slide, number, title, body, x, y, w=3.65, h=1.28, fill=PAPER):
    add_rect(slide, x, y, w, h, fill=fill, line=LINE)
    circle = slide.shapes.add_shape(MSO_AUTO_SHAPE_TYPE.OVAL, Inches(x + 0.18), Inches(y + 0.23), Inches(0.58), Inches(0.58))
    circle.fill.solid()
    circle.fill.fore_color.rgb = rgb(ORANGE)
    circle.line.fill.background()
    add_text(slide, str(number), x + 0.18, y + 0.29, 0.58, 0.25, size=13, color=WHITE, bold=True, align=PP_ALIGN.CENTER)
    add_text(slide, title, x + 0.92, y + 0.18, w - 1.08, 0.28, size=14, color=BROWN, bold=True)
    add_text(slide, body, x + 0.92, y + 0.54, w - 1.08, 0.56, size=10.5, color=MUTED)


def add_notes(slide, notes):
    frame = slide.notes_slide.notes_text_frame
    frame.text = notes.strip()


def set_background(slide, color=CREAM):
    background = slide.background
    background.fill.solid()
    background.fill.fore_color.rgb = rgb(color)


def add_timing(slide, text, x=11.25, y=0.44, w=1.32):
    add_pill(slide, text, x, y, w, fill=GREEN_BG, color=GREEN, size=9)


def add_demo_badge(slide, text="LIVE DEMO"):
    add_pill(slide, text, 10.92, 0.43, 1.65, fill=PEACH, color=ORANGE, size=9)


def add_check(slide, text, x, y, w, color=GREEN):
    circle = slide.shapes.add_shape(MSO_AUTO_SHAPE_TYPE.OVAL, Inches(x), Inches(y), Inches(0.32), Inches(0.32))
    circle.fill.solid()
    circle.fill.fore_color.rgb = rgb(color)
    circle.line.fill.background()
    add_text(slide, "✓", x + 0.01, y + 0.02, 0.3, 0.22, size=11, color=WHITE, bold=True, align=PP_ALIGN.CENTER)
    add_text(slide, text, x + 0.46, y - 0.01, w - 0.46, 0.43, size=12, color=INK)


def remove_click_action(shape):
    # Prevent accidental hyperlink/click actions from inherited layouts.
    c_nv_pr = shape._element.xpath(".//p:cNvPr")
    if c_nv_pr:
        for child in list(c_nv_pr[0]):
            if child.tag.endswith("hlinkClick"):
                c_nv_pr[0].remove(child)


def build_deck():
    presentation = Presentation()
    presentation.slide_width = Inches(SLIDE_W)
    presentation.slide_height = Inches(SLIDE_H)
    blank = presentation.slide_layouts[6]

    # 1 — Title
    slide = presentation.slides.add_slide(blank)
    set_background(slide, BROWN)
    add_rect(slide, 7.65, -0.45, 6.3, 8.2, fill=ORANGE, line=ORANGE, radius=False, line_width=0)
    add_rect(slide, 8.15, 0.55, 4.45, 6.4, fill=CREAM, line=CREAM, radius=True, line_width=0)
    add_image_contain(slide, LOGO, 8.83, 1.24, 3.15, 2.35)
    add_text(slide, "VILLI’S CAFE", 0.78, 1.24, 6.2, 0.7, size=34, color=WHITE, bold=True, font="Aptos Display")
    add_text(slide, "Project Demonstration", 0.8, 2.12, 5.8, 0.58, size=25, color="FFD7C0", bold=True)
    add_text(slide, "A local-first Android café ordering experience", 0.82, 2.92, 5.75, 0.82, size=17, color=WHITE)
    add_pill(slide, "15 MINUTES", 0.82, 4.14, 1.55, fill=ORANGE, color=WHITE, size=9)
    add_text(slide, "10 min  Project and system demo\n5 min   Individual contribution", 0.83, 4.78, 5.2, 0.8, size=14, color=WHITE, bold=True)
    add_text(slide, "Presenter: ____________________", 0.83, 6.44, 5.8, 0.35, size=11, color="EFC6B1")
    add_notes(slide, """
Time: 0:00–0:30

Good morning/afternoon. This presentation demonstrates Villi’s Cafe, an Android ordering application developed with Flutter. The first ten minutes explain the problem, objectives, architecture, object-oriented design, and the working system. The final five minutes cover the individual contribution, technology decisions, and risk management.

Do not spend time reading the title slide. Move directly to the problem.
""")

    # 2 — Problem
    slide = presentation.slides.add_slide(blank)
    set_background(slide)
    add_title(slide, "The ordering journey was fragmented", "Problem", "A small café needed the useful parts of a delivery app—without marketplace complexity.")
    add_timing(slide, "0:30–1:30")
    add_rect(slide, 0.75, 2.3, 5.1, 3.95, fill=PAPER, line=LINE)
    add_text(slide, "Observed customer friction", 1.05, 2.64, 4.5, 0.35, size=18, color=BROWN, bold=True)
    add_rich_lines(
        slide,
        [
            "Menu discovery depended on being at the café",
            "Order totals were not visible before checkout",
            "Promotions, loyalty, and order status were disconnected",
            "Large delivery platforms added fees and unnecessary scope",
        ],
        1.07,
        3.2,
        4.35,
        2.45,
        size=14,
        bullet=True,
        gap=13,
    )
    add_rect(slide, 6.2, 2.3, 6.37, 3.95, fill=BROWN, line=BROWN)
    add_text(slide, "Design question", 6.6, 2.67, 4.9, 0.3, size=12, color="F6C8B0", bold=True)
    add_text(slide, "How could one small Android app support discovery, ordering, and follow-up while keeping data local and the code understandable?", 6.6, 3.22, 5.15, 1.55, size=24, color=WHITE, bold=True, font="Aptos Display")
    add_text(slide, "Constraint-led justification", 6.6, 5.15, 4.8, 0.3, size=11, color="F6C8B0", bold=True)
    add_text(slide, "No real payment gateway • No complex backend • Android coursework scope", 6.6, 5.56, 5.15, 0.42, size=12, color=WHITE)
    add_footer(slide, 2)
    add_notes(slide, """
Time: 0:30–1:30

The identified problem was not simply “the café needs an app.” The real issue was a fragmented customer journey. Customers could not browse comfortably before arrival, understand a total, or keep promotions and order follow-up in one place. Commercial delivery platforms solve this at marketplace scale, but they introduce fees, remote infrastructure, and operational complexity that did not fit a small undergraduate project.

The solution therefore had to reproduce the valuable interaction pattern while remaining local, explainable, and safe to demonstrate.
""")

    # 3 — Solution and objectives
    slide = presentation.slides.add_slide(blank)
    set_background(slide)
    add_title(slide, "One local-first flow from discovery to loyalty", "Solution and objectives", "The application joined the complete café journey without processing real money.")
    add_timing(slide, "1:30–2:45")
    add_phone(slide, SCREENSHOTS / "09_customer_home.png", 0.9, 2.35, 4.15)
    add_text(slide, "Villi’s Cafe combined", 3.25, 2.45, 3.25, 0.42, size=20, color=BROWN, bold=True)
    add_rich_lines(
        slide,
        [
            "Local authentication and role-based entry",
            "Searchable products and categories",
            "Persistent cart and validated checkout",
            "Order confirmation, history, and loyalty",
            "Promotions, notifications, and café chat",
            "Administrator product/order/chat controls",
        ],
        3.27,
        3.05,
        3.55,
        2.85,
        size=12.5,
        bullet=True,
        gap=8,
    )
    add_number_card(slide, 1, "Clear", "A five-tab customer journey with explicit actions.", 7.08, 2.32, 2.48, 1.32)
    add_number_card(slide, 2, "Reliable", "SQLite persistence, constraints, and atomic ordering.", 9.83, 2.32, 2.48, 1.32)
    add_number_card(slide, 3, "Safe", "Simulated payment; card values never persisted.", 7.08, 3.93, 2.48, 1.32)
    add_number_card(slide, 4, "Testable", "Layered code with provider and widget tests.", 9.83, 3.93, 2.48, 1.32)
    add_rect(slide, 7.08, 5.56, 5.23, 0.72, fill=GREEN_BG, line=GREEN_BG)
    add_text(slide, "Outcome: a complete Android demo, not a production payment service.", 7.35, 5.78, 4.7, 0.24, size=11.5, color=GREEN, bold=True, align=PP_ALIGN.CENTER)
    add_footer(slide, 3)
    add_notes(slide, """
Time: 1:30–2:45

The solution was a local-first Flutter application that joined discovery, cart management, checkout, order history, loyalty, promotions, notifications, chat, and administration. The four objectives were clarity, reliability, safety, and testability.

Clarity came from a consistent five-tab customer shell. Reliability came from SQLite persistence and atomic order placement. Safety came from openly simulated payments and the decision not to save card fields. Testability came from separating UI, state, and persistence so each layer could be checked independently.
""")

    # 4 — Architecture
    slide = presentation.slides.add_slide(blank)
    set_background(slide)
    add_title(slide, "The architecture kept UI state separate from SQL", "Architecture", "A layered design made every action traceable and easier to test.")
    add_timing(slide, "2:45–4:00")
    add_rect(slide, 0.75, 2.25, 8.12, 4.2, fill=WHITE, line=LINE)
    add_image_contain(slide, DIAGRAMS / "high_level_architecture.png", 0.96, 2.44, 7.7, 3.78)
    add_rect(slide, 9.18, 2.25, 3.38, 4.2, fill=PAPER, line=LINE)
    add_text(slide, "Example data flow", 9.5, 2.62, 2.72, 0.32, size=16, color=BROWN, bold=True)
    flow = [
        ("1", "Tap Add to Cart", ORANGE),
        ("2", "CartProvider updates state", ORANGE_2),
        ("3", "CartRepository executes SQL", BLUE),
        ("4", "SQLite persists quantity", GREEN),
        ("5", "Provider reloads the cart", BROWN),
    ]
    y = 3.13
    for number, label, color in flow:
        circle = slide.shapes.add_shape(MSO_AUTO_SHAPE_TYPE.OVAL, Inches(9.48), Inches(y), Inches(0.44), Inches(0.44))
        circle.fill.solid()
        circle.fill.fore_color.rgb = rgb(color)
        circle.line.fill.background()
        add_text(slide, number, 9.49, y + 0.08, 0.42, 0.2, size=9, color=WHITE, bold=True, align=PP_ALIGN.CENTER)
        add_text(slide, label, 10.08, y + 0.04, 2.06, 0.34, size=11, color=INK, bold=True)
        y += 0.59
    add_footer(slide, 4)
    add_notes(slide, """
Time: 2:45–4:00

The architecture used four layers. Screens and widgets handled presentation. Provider and ChangeNotifier represented observable state, including loading and error states. Repositories owned database operations, while DatabaseService created and upgraded SQLite.

For example, an Add to Cart tap did not contain SQL. It called CartProvider, which called CartRepository. SQLite persisted the quantity, and the provider reloaded the cart so the interface updated. This separation reduced coupling and made provider behaviour testable with repository stubs.
""")

    # 5 — OOP concepts
    slide = presentation.slides.add_slide(blank)
    set_background(slide)
    add_title(slide, "OOP concepts appeared in working code—not only diagrams", "Object-oriented development", "Dart classes modelled the domain and isolated change.")
    add_timing(slide, "4:00–5:15")
    cards = [
        ("Encapsulation", "Private provider state such as _items and _isLoading was exposed through controlled getters and methods.", "CartProvider • OrderProvider"),
        ("Abstraction", "Repositories hid SQL details from widgets; screens worked with domain operations instead of database statements.", "CartRepository • OrderRepository"),
        ("Inheritance", "Widgets extended StatelessWidget or StatefulWidget; providers extended ChangeNotifier.", "ProfileScreen • ProductCard"),
        ("Polymorphism", "Test repositories overrode methods to simulate success and failure without changing production providers.", "Repository stubs in tests"),
        ("Composition", "MultiProvider assembled services, while screens composed reusable cards, images, banners, and navigation.", "QuickBiteApp • MainShell"),
        ("Typed models", "Product, CartItem, OrderModel, AppUser, and ChatMessage protected data shape across layers.", "fromMap • toMap • copyWith"),
    ]
    positions = [(0.75, 2.27), (4.36, 2.27), (7.97, 2.27), (0.75, 4.37), (4.36, 4.37), (7.97, 4.37)]
    for (title, body, evidence), (x, y) in zip(cards, positions):
        add_rect(slide, x, y, 3.24, 1.72, fill=PAPER, line=LINE)
        add_text(slide, title, x + 0.24, y + 0.22, 2.76, 0.28, size=15, color=BROWN, bold=True)
        add_text(slide, body, x + 0.24, y + 0.59, 2.76, 0.7, size=10.2, color=INK)
        add_text(slide, evidence, x + 0.24, y + 1.38, 2.76, 0.18, size=8.3, color=ORANGE, bold=True)
    add_footer(slide, 5)
    add_notes(slide, """
Time: 4:00–5:15

Object orientation was visible in the implemented system. Providers encapsulated private state. Repositories abstracted persistence. Flutter widgets and ChangeNotifier demonstrated inheritance. Test doubles demonstrated polymorphism by overriding repository operations. Composition appeared in MultiProvider and the reuse of smaller widgets. Finally, typed domain models carried consistent data across the architecture.

Point to one source example for each concept if asked. Avoid giving textbook definitions without connecting them to this project.
""")

    # 6 — Demo map
    slide = presentation.slides.add_slide(blank)
    set_background(slide, BROWN)
    add_text(slide, "START THE SCREEN RECORDING", 0.78, 0.7, 6.1, 0.35, size=12, color="F7C7AD", bold=True)
    add_text(slide, "Live system demonstration", 0.78, 1.23, 7.2, 0.72, size=32, color=WHITE, bold=True, font="Aptos Display")
    add_text(slide, "Follow one continuous story so every operation has a reason.", 0.8, 2.08, 6.85, 0.4, size=15, color="F8DCCD")
    steps = [
        ("01", "Sign in", "Show local account entry"),
        ("02", "Discover", "Search, category, details"),
        ("03", "Order", "Cart, checkout, confirmation"),
        ("04", "Follow up", "Orders, loyalty, chat"),
        ("05", "Admin", "Products, status, replies"),
    ]
    y = 3.0
    for number, title, body in steps:
        add_text(slide, number, 0.82, y, 0.5, 0.26, size=10, color=ORANGE_2, bold=True)
        add_text(slide, title, 1.45, y - 0.03, 1.7, 0.3, size=15, color=WHITE, bold=True)
        add_text(slide, body, 3.2, y, 3.65, 0.28, size=11, color="E9CDBF")
        y += 0.64
    add_rect(slide, 8.14, 0.62, 4.43, 6.23, fill=CREAM, line=CREAM)
    add_phone(slide, SCREENSHOTS / "10_menu.png", 9.44, 1.02, 5.2)
    add_pill(slide, "5-MINUTE LIVE WALKTHROUGH", 8.84, 6.38, 3.2, fill=ORANGE, color=WHITE, size=9)
    add_notes(slide, """
Time: 5:15–5:45

Start or confirm the video recording now. Switch from the slides to the Android emulator. Keep the narration continuous and explain the purpose of each action instead of silently tapping.

Demo order:
1. Sign in or use the prepared local customer account.
2. Home → promotion/search/categories.
3. Menu → filter → product details → quantity → Add to Cart.
4. Cart → checkout → complete safe demo details → Cash on Delivery → Place Order.
5. Confirmation → Orders → Profile loyalty → customer chat.
6. Log out and open the local administrator account → products → orders → chat.

If the live app fails, use the next three screenshot slides as a narrated recovery route.
""")

    # 7 — Customer demo
    slide = presentation.slides.add_slide(blank)
    set_background(slide)
    add_title(slide, "Demo 1 — discover the right item quickly", "System functionality", "Home, search, category filters, product details, and quantity selection.")
    add_demo_badge(slide)
    add_phone(slide, SCREENSHOTS / "09_customer_home.png", 0.82, 2.24, 4.35, "HOME")
    add_phone(slide, SCREENSHOTS / "10_menu.png", 3.34, 2.24, 4.35, "MENU")
    add_phone(slide, SCREENSHOTS / "11_product_details.png", 5.86, 2.24, 4.35, "DETAILS")
    add_rect(slide, 8.55, 2.25, 3.99, 4.42, fill=PAPER, line=LINE)
    add_text(slide, "Narrate while tapping", 8.9, 2.6, 3.25, 0.32, size=17, color=BROWN, bold=True)
    add_check(slide, "Promotion carousel communicates current offers", 8.92, 3.18, 3.13)
    add_check(slide, "Search and categories reuse ProductProvider state", 8.92, 3.95, 3.13)
    add_check(slide, "Product details show price, rating, and description", 8.92, 4.72, 3.13)
    add_check(slide, "Quantity updates the selected total before cart entry", 8.92, 5.49, 3.13)
    add_footer(slide, 7)
    add_notes(slide, """
Time: 5:45–7:30 (mostly in the emulator)

On Home, identify the promotion carousel, search entry, and four categories. Open Menu and show that category selection and text search change the visible products. Open a product and explain that the typed Product model supplies the name, category, price, description, image URL, and rating. Increase the quantity once, show the selected total, then add the item to the cart.

Justification: this journey reduces discovery effort and provides price transparency before checkout.
""")

    # 8 — Order demo
    slide = presentation.slides.add_slide(blank)
    set_background(slide)
    add_title(slide, "Demo 2 — convert the cart into a trusted order", "System functionality", "Validation, simulated payment, atomic persistence, and confirmation.")
    add_demo_badge(slide)
    add_phone(slide, SCREENSHOTS / "13_checkout.png", 0.82, 2.22, 4.4, "DELIVERY + PAYMENT")
    add_phone(slide, SCREENSHOTS / "14_checkout_summary.png", 3.38, 2.22, 4.4, "ORDER SUMMARY")
    add_phone(slide, SCREENSHOTS / "15_order_confirmation.png", 5.94, 2.22, 4.4, "CONFIRMATION")
    add_rect(slide, 8.68, 2.22, 3.85, 4.46, fill=BROWN, line=BROWN)
    add_text(slide, "Trust controls", 9.02, 2.62, 3.0, 0.35, size=18, color=WHITE, bold=True)
    add_rich_lines(
        slide,
        [
            "Required delivery fields",
            "Three clearly simulated payment choices",
            "Luhn, expiry, and CVV validation for card demo",
            "Card values never written to SQLite",
            "Order insert + cart clear in one transaction",
        ],
        9.03,
        3.24,
        3.02,
        2.85,
        size=12,
        color=WHITE,
        bullet=True,
        gap=11,
        icon_color=ORANGE_2,
    )
    add_footer(slide, 8)
    add_notes(slide, """
Time: 7:30–9:00 (mostly in the emulator)

Open Cart and explain the subtotal, fixed delivery charge, and total. Proceed to Checkout. First submit an empty required field if time allows to demonstrate validation. Select Cash on Delivery for the fastest recording route, but point out that card and wallet are simulations.

Place the order. Explain that OrderRepository recalculates the authoritative total from SQLite, inserts the order, and clears the cart inside one transaction. Show the friendly order number and preparing status on the confirmation screen.

Privacy justification: cardholder name, number, expiry, and CVV remain only in the form and are not saved in the orders table.
""")

    # 9 — Follow-up and admin demo
    slide = presentation.slides.add_slide(blank)
    set_background(slide)
    add_title(slide, "Demo 3 — close the loop for customers and staff", "System functionality", "Order follow-up, loyalty, administrator maintenance, and communication.")
    add_demo_badge(slide)
    add_phone(slide, SCREENSHOTS / "16_profile_loyalty.png", 0.9, 2.22, 4.34, "CUSTOMER PROFILE")
    add_phone(slide, SCREENSHOTS / "08_admin_dashboard.png", 3.45, 2.22, 4.34, "ADMIN PRODUCTS")
    add_rect(slide, 6.16, 2.25, 6.36, 1.23, fill=GREEN_BG, line=GREEN_BG)
    add_text(slide, "Customer value", 6.48, 2.53, 1.65, 0.28, size=14, color=GREEN, bold=True)
    add_text(slide, "Saved order history • 1 point per Rs. 100 • promotions • notifications • café chat", 8.15, 2.48, 4.0, 0.46, size=11.5, color=INK, bold=True)
    add_rect(slide, 6.16, 3.78, 6.36, 1.23, fill=BLUE_BG, line=BLUE_BG)
    add_text(slide, "Staff control", 6.48, 4.06, 1.65, 0.28, size=14, color=BLUE, bold=True)
    add_text(slide, "Add/edit/delete products • update order status • reply to customer conversations", 8.15, 4.01, 4.0, 0.46, size=11.5, color=INK, bold=True)
    add_rect(slide, 6.16, 5.31, 6.36, 1.23, fill=PEACH, line=PEACH)
    add_text(slide, "Role boundary", 6.48, 5.59, 1.65, 0.28, size=14, color=ORANGE, bold=True)
    add_text(slide, "AuthProvider restores one local session and routes customer or administrator UI", 8.15, 5.54, 4.0, 0.46, size=11.5, color=INK, bold=True)
    add_footer(slide, 9)
    add_notes(slide, """
Time: 9:00–10:30

From the confirmation, return to the main shell and show Orders or Profile. Explain that loyalty uses qualifying non-cancelled order totals and awards one point per Rs. 100. Open chat briefly to show the customer communication entry point.

Then log out and demonstrate the administrator role. Show product maintenance, order status controls, and the chat destination. Explain that the same local SQLite data is presented differently according to the restored role.

End the project demonstration here and return to the slides for the individual contribution section.
""")

    # 10 — Contribution
    slide = presentation.slides.add_slide(blank)
    set_background(slide)
    add_title(slide, "My contribution covered the complete delivery path", "Individual contribution", "Repository evidence showed an incremental implementation across the full system.")
    add_timing(slide, "10:30–12:00")
    add_pill(slide, "INDIVIDUAL CONTRIBUTION • 5 MIN", 9.76, 0.43, 2.82, fill=BROWN, color=WHITE, size=9)
    add_rect(slide, 0.75, 2.25, 2.42, 3.95, fill=BROWN, line=BROWN)
    add_text(slide, "23", 1.04, 2.72, 1.82, 0.78, size=40, color=WHITE, bold=True, font="Aptos Display", align=PP_ALIGN.CENTER)
    add_text(slide, "incremental commits", 1.04, 3.53, 1.82, 0.3, size=12, color="F7D7C6", bold=True, align=PP_ALIGN.CENTER)
    add_text(slide, "42", 1.04, 4.28, 1.82, 0.78, size=40, color=WHITE, bold=True, font="Aptos Display", align=PP_ALIGN.CENTER)
    add_text(slide, "passing tests", 1.04, 5.09, 1.82, 0.3, size=12, color="F7D7C6", bold=True, align=PP_ALIGN.CENTER)
    phases = [
        ("Foundation", "Theme, models, database, repositories, providers"),
        ("Customer journey", "Browse, details, cart, checkout, orders, profile"),
        ("Extended operations", "Authentication, admin, chat, notifications, dark mode"),
        ("Quality", "Responsive states, accessibility, resilience tests, documentation"),
    ]
    y = 2.3
    for index, (title, body) in enumerate(phases, 1):
        add_number_card(slide, index, title, body, 3.55, y, 4.15, 1.05, fill=PAPER)
        y += 1.24
    add_rect(slide, 8.08, 2.25, 4.46, 3.95, fill=PAPER, line=LINE)
    add_text(slide, "Demonstrate contribution with evidence", 8.42, 2.61, 3.78, 0.54, size=17, color=BROWN, bold=True)
    add_rich_lines(
        slide,
        [
            ("Code: ", "open one provider/repository pair"),
            ("Database: ", "show the transaction and schema"),
            ("UI: ", "connect a live screen to its state"),
            ("Tests: ", "show the 42-test result"),
            ("Git: ", "show ordered feature commits"),
        ],
        8.44,
        3.43,
        3.66,
        2.25,
        size=12.5,
        bullet=True,
        gap=10,
    )
    add_footer(slide, 10, section="INDIVIDUAL CONTRIBUTION")
    add_notes(slide, """
Time: 10:30–12:00

This section explains the individual contribution using evidence rather than a feature list. The repository contains 23 incremental commits spanning the architecture, customer flow, administrator operations, resilience, tests, and documentation. The final suite contains 42 passing tests.

Demonstrate one traceable contribution: open CartProvider and CartRepository, then connect them to the cart operation already shown in the app. Alternatively, open OrderRepository.placeOrder and explain the transaction. Show the Git log briefly to establish the implementation sequence.

Keep the contributor name blank on the slide as requested; state it verbally only if required by the assessor.
""")

    # 11 — Technology justification
    slide = presentation.slides.add_slide(blank)
    set_background(slide)
    add_title(slide, "Each technology matched a specific project constraint", "Technology choices", "The stack stayed small enough to explain while supporting persistence and quality.")
    add_timing(slide, "12:00–13:15")
    choices = [
        ("Flutter + Dart", "One Android UI codebase", "Widget composition, typed models, hot reload"),
        ("Material 3", "Consistent and accessible interface", "NavigationBar, forms, cards, colour schemes"),
        ("Provider", "Simple observable state", "ChangeNotifier matched the app’s undergraduate scale"),
        ("SQLite + sqflite", "Reliable local persistence", "Offline cart, orders, users, chat, transactions"),
        ("crypto", "Avoid plain-text demo passwords", "SHA-256 hash stored locally; not claimed as production auth"),
        ("Flutter test + Git", "Evidence and change control", "42 tests, responsive cases, incremental commits"),
    ]
    positions = [(0.75, 2.3), (4.36, 2.3), (7.97, 2.3), (0.75, 4.4), (4.36, 4.4), (7.97, 4.4)]
    for (tech, reason, evidence), (x, y) in zip(choices, positions):
        add_rect(slide, x, y, 3.24, 1.72, fill=PAPER, line=LINE)
        add_text(slide, tech, x + 0.23, y + 0.22, 2.8, 0.3, size=15, color=ORANGE, bold=True)
        add_text(slide, reason, x + 0.23, y + 0.62, 2.8, 0.34, size=11.5, color=BROWN, bold=True)
        add_text(slide, evidence, x + 0.23, y + 1.05, 2.8, 0.5, size=9.6, color=MUTED)
    add_footer(slide, 11, section="INDIVIDUAL CONTRIBUTION")
    add_notes(slide, """
Time: 12:00–13:15

Justify each technology through the running system. Flutter and Dart supported a single typed Android UI. Material 3 supplied familiar accessible components. Provider was sufficient for a small ChangeNotifier architecture without unnecessary complexity. SQLite matched the local-first requirement and provided transactions. The crypto package prevented plain-text demonstration passwords, although this was not presented as production authentication. Flutter tests and Git supplied repeatable quality and contribution evidence.

Avoid saying a technology was selected only because it is popular. Tie every choice to a requirement or constraint.
""")

    # 12 — Risks
    slide = presentation.slides.add_slide(blank)
    set_background(slide)
    add_title(slide, "Risks were reduced through design decisions and tests", "Risk management", "The main risks were scope, data consistency, privacy, connectivity, and device variation.")
    add_timing(slide, "13:15–14:30")
    rows = [
        ("Scope creep", "High", "Feature phases; local data; simulated payment; explicit exclusions"),
        ("Order/cart inconsistency", "High", "SQLite transaction recalculated total, inserted order, and cleared cart atomically"),
        ("Sensitive payment data", "High", "No gateway; no card fields persisted; clear simulation messages"),
        ("Duplicate committed actions", "Medium", "Provider resilience prevented retry after a successful mutation and failed refresh"),
        ("Network image failure", "Medium", "ProductImage displayed a branded placeholder on error"),
        ("Small/large screens", "Medium", "LayoutBuilder, responsive grids, semantics, large-text and landscape tests"),
    ]
    # Table header
    add_rect(slide, 0.75, 2.27, 11.8, 0.54, fill=BROWN, line=BROWN, radius=False)
    add_text(slide, "RISK", 1.02, 2.42, 2.3, 0.2, size=10, color=WHITE, bold=True)
    add_text(slide, "LEVEL", 3.54, 2.42, 1.15, 0.2, size=10, color=WHITE, bold=True)
    add_text(slide, "MANAGEMENT IN THE SYSTEM", 4.82, 2.42, 6.9, 0.2, size=10, color=WHITE, bold=True)
    y = 2.82
    for index, (risk, level, response) in enumerate(rows):
        fill = PAPER if index % 2 == 0 else "FFF3EB"
        add_rect(slide, 0.75, y, 11.8, 0.61, fill=fill, line=LINE, radius=False, line_width=0.5)
        add_text(slide, risk, 1.02, y + 0.17, 2.34, 0.24, size=11.2, color=INK, bold=True)
        level_fill = RED if level == "High" else ORANGE
        add_pill(slide, level, 3.52, y + 0.13, 0.8, fill=level_fill, color=WHITE, size=8)
        add_text(slide, response, 4.82, y + 0.12, 7.15, 0.37, size=10.3, color=INK)
        y += 0.64
    add_rect(slide, 0.75, 6.73, 11.8, 0.3, fill=GREEN_BG, line=GREEN_BG, radius=True, line_width=0)
    add_text(slide, "Risk treatment was visible in architecture, UI messages, database rules, and automated tests.", 1.0, 6.78, 11.25, 0.16, size=8.5, color=GREEN, bold=True, align=PP_ALIGN.CENTER)
    add_footer(slide, 12, section="INDIVIDUAL CONTRIBUTION")
    add_notes(slide, """
Time: 13:15–14:30

The highest risks were scope, inconsistent order data, and payment privacy. Scope was controlled through staged delivery and explicit exclusions. The order transaction protected consistency. Payment was simulated and card values were excluded from persistence.

Two implementation-specific risks also mattered. A successful write followed by a failed refresh could tempt the UI to retry and duplicate an action; resilience tests confirmed that providers instead reported the refresh failure without retrying the committed mutation. Network image failures used placeholders, and responsive tests covered narrow, landscape, and large-text layouts.
""")

    # 13 — Validation and finish
    slide = presentation.slides.add_slide(blank)
    set_background(slide, BROWN)
    add_text(slide, "VALIDATED OUTCOME", 0.8, 0.72, 3.2, 0.3, size=11, color="F4C5AD", bold=True)
    add_text(slide, "A complete, explainable Android ordering journey", 0.8, 1.22, 7.1, 1.05, size=31, color=WHITE, bold=True, font="Aptos Display")
    add_text(slide, "The solution met its coursework objectives while clearly stating its production boundaries.", 0.82, 2.52, 6.8, 0.6, size=15, color="F7DCCD")
    add_rect(slide, 0.82, 3.53, 2.08, 1.58, fill=ORANGE, line=ORANGE)
    add_text(slide, "42", 1.03, 3.75, 1.66, 0.6, size=32, color=WHITE, bold=True, align=PP_ALIGN.CENTER)
    add_text(slide, "tests passed", 1.03, 4.45, 1.66, 0.25, size=11, color=WHITE, bold=True, align=PP_ALIGN.CENTER)
    add_rect(slide, 3.15, 3.53, 2.08, 1.58, fill=CREAM, line=CREAM)
    add_text(slide, "0", 3.36, 3.75, 1.66, 0.6, size=32, color=BROWN, bold=True, align=PP_ALIGN.CENTER)
    add_text(slide, "analyzer issues", 3.36, 4.45, 1.66, 0.25, size=11, color=BROWN, bold=True, align=PP_ALIGN.CENTER)
    add_rect(slide, 5.48, 3.53, 2.08, 1.58, fill=GREEN_BG, line=GREEN_BG)
    add_text(slide, "1", 5.69, 3.75, 1.66, 0.6, size=32, color=GREEN, bold=True, align=PP_ALIGN.CENTER)
    add_text(slide, "Android walkthrough", 5.65, 4.4, 1.74, 0.42, size=10.5, color=GREEN, bold=True, align=PP_ALIGN.CENTER)
    add_rect(slide, 8.15, 0.62, 4.45, 6.26, fill=CREAM, line=CREAM)
    add_image_contain(slide, LOGO, 9.12, 1.0, 2.5, 1.9)
    add_text(slide, "Thank you", 8.75, 3.28, 3.25, 0.48, size=26, color=BROWN, bold=True, align=PP_ALIGN.CENTER)
    add_text(slide, "Questions and demonstration follow-up", 8.72, 4.03, 3.32, 0.58, size=13, color=MUTED, align=PP_ALIGN.CENTER)
    add_pill(slide, "VILLI’S CAFE", 9.27, 5.33, 2.22, fill=PEACH, color=ORANGE, size=10)
    add_text(slide, "Presenter: ____________________", 8.82, 6.15, 3.1, 0.25, size=9.5, color=MUTED, align=PP_ALIGN.CENTER)
    add_notes(slide, """
Time: 14:30–15:00

Conclude with evidence. The final build ran on Android, static analysis found no issues, and all 42 automated tests passed. The project achieved a complete local ordering journey and made its boundaries—especially simulated payments and local-only synchronisation—clear.

Thank the audience and invite questions. Keep the emulator available in case an assessor asks to revisit a feature or source file.
""")

    # 14 — Backup demo recovery
    slide = presentation.slides.add_slide(blank)
    set_background(slide)
    add_title(slide, "Backup — demo recovery route", "Do not present unless needed", "Use these prepared captures if the emulator or network image loading fails.")
    add_pill(slide, "BACKUP", 11.28, 0.43, 1.28, fill=RED, color=WHITE, size=9)
    screenshots = [
        ("HOME", "09_customer_home.png"),
        ("MENU", "10_menu.png"),
        ("DETAILS", "11_product_details.png"),
        ("CHECKOUT", "14_checkout_summary.png"),
        ("CONFIRM", "15_order_confirmation.png"),
        ("ADMIN", "08_admin_dashboard.png"),
    ]
    x = 0.82
    for label, filename in screenshots:
        add_phone(slide, SCREENSHOTS / filename, x, 2.28, 3.85, label)
        x += 2.08
    add_rect(slide, 0.82, 6.55, 11.7, 0.38, fill=PEACH, line=PEACH)
    add_text(slide, "Recovery narration: discovery → cart/checkout → confirmation → customer follow-up → administrator control", 1.08, 6.65, 11.2, 0.16, size=9.5, color=ORANGE, bold=True, align=PP_ALIGN.CENTER)
    add_footer(slide, 14, section="BACKUP")
    add_notes(slide, """
Backup only.

If the emulator fails, narrate the same end-to-end journey from left to right. State clearly that these are real screenshots captured from the Android emulator during report preparation, not mock-ups.
""")

    # 15 — Backup technical evidence
    slide = presentation.slides.add_slide(blank)
    set_background(slide)
    add_title(slide, "Backup — database and verification evidence", "Do not present unless asked", "Use this slide for deeper architecture, privacy, or testing questions.")
    add_pill(slide, "BACKUP", 11.28, 0.43, 1.28, fill=RED, color=WHITE, size=9)
    add_rect(slide, 0.75, 2.25, 8.06, 4.32, fill=WHITE, line=LINE)
    add_image_contain(slide, DIAGRAMS / "er_diagram.png", 0.95, 2.42, 7.66, 3.95)
    add_rect(slide, 9.13, 2.25, 3.41, 4.32, fill=PAPER, line=LINE)
    add_text(slide, "Evidence ready", 9.48, 2.63, 2.7, 0.32, size=17, color=BROWN, bold=True)
    add_check(slide, "6 SQLite tables", 9.49, 3.25, 2.6)
    add_check(slide, "Foreign keys + constraints", 9.49, 3.86, 2.6)
    add_check(slide, "Versioned migrations", 9.49, 4.47, 2.6)
    add_check(slide, "Atomic place-order transaction", 9.49, 5.08, 2.6)
    add_check(slide, "No card credentials persisted", 9.49, 5.69, 2.6)
    add_footer(slide, 15, section="BACKUP")
    add_notes(slide, """
Backup only.

The schema contains users, auth_session, chat_messages, products, cart_items, and orders. Products and cart items are related; users own sessions and chat messages. Orders deliberately keep a delivery snapshot and contain no card-number, expiry, or CVV fields. Database version 4 introduced staged migrations. The place-order transaction is the key reliability control.
""")

    # Store simple metadata.
    presentation.core_properties.title = "Villi’s Cafe – Project Demonstration"
    presentation.core_properties.subject = "PUSL2023 project demonstration and individual contribution"
    presentation.core_properties.author = ""
    presentation.core_properties.last_modified_by = ""
    presentation.core_properties.created = datetime(2026, 8, 25)
    presentation.core_properties.modified = datetime(2026, 8, 25)
    presentation.core_properties.keywords = "Flutter, Dart, SQLite, Provider, Android, café ordering"
    presentation.core_properties.comments = "15-minute deck with presenter notes and live-demo prompts."

    PRESENTATION_DIR.mkdir(parents=True, exist_ok=True)
    presentation.save(OUTPUT)
    return OUTPUT


if __name__ == "__main__":
    print(build_deck())
