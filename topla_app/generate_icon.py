from PIL import Image, ImageDraw, ImageFont
import math

def create_app_icon(size=1024, save_path="app_icon.png"):
    """Savat belgisi + TOPLA matnli ilova ikonkasi"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Background - rounded rectangle with gradient effect
    # Create gradient manually
    for y in range(size):
        ratio = y / size
        r = int(255 * (1 - ratio * 0.3))  # FF -> ~B3
        g = int(140 * (1 - ratio * 0.4) - ratio * 30)  # 8C -> ~55
        b = int(ratio * 0)  # 00 -> 00
        r = max(0, min(255, r))
        g = max(0, min(255, g))
        b = max(0, min(255, b))
        draw.line([(0, y), (size - 1, y)], fill=(r, g, b, 255))
    
    # Apply rounded corners mask
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    corner_radius = size // 5  # ~204px
    mask_draw.rounded_rectangle([(0, 0), (size - 1, size - 1)], radius=corner_radius, fill=255)
    img.putalpha(mask)
    
    # Draw shopping cart
    cx, cy = size // 2, size * 0.44  # Center of cart
    scale = size / 1024.0
    line_w = int(38 * scale)
    white = (255, 255, 255, 255)
    
    # Cart handle
    handle_start = (cx - int(290 * scale), cy - int(155 * scale))
    handle_end = (cx - int(235 * scale), cy - int(100 * scale))
    draw.line([handle_start, handle_end], fill=white, width=line_w)
    # Round caps
    r_cap = line_w // 2
    draw.ellipse([handle_start[0]-r_cap, handle_start[1]-r_cap, handle_start[0]+r_cap, handle_start[1]+r_cap], fill=white)
    
    # Cart body - draw as connected lines
    points_cart = [
        (cx - int(235 * scale), cy - int(100 * scale)),  # Start after handle
        (cx - int(175 * scale), cy + int(95 * scale)),   # Bottom left
        (cx + int(195 * scale), cy + int(95 * scale)),   # Bottom right
        (cx + int(250 * scale), cy - int(55 * scale)),   # Top right
        (cx - int(120 * scale), cy - int(55 * scale)),   # Back to cart opening
    ]
    
    for i in range(len(points_cart) - 1):
        draw.line([points_cart[i], points_cart[i+1]], fill=white, width=line_w)
        # Round joints
        p = points_cart[i]
        draw.ellipse([p[0]-r_cap, p[1]-r_cap, p[0]+r_cap, p[1]+r_cap], fill=white)
    # Last point cap
    p = points_cart[-1]
    draw.ellipse([p[0]-r_cap, p[1]-r_cap, p[0]+r_cap, p[1]+r_cap], fill=white)
    
    # Cart wheels
    wheel_r = int(32 * scale)
    wheel_y = cy + int(165 * scale)
    # Left wheel
    draw.ellipse([cx - int(120*scale) - wheel_r, wheel_y - wheel_r, 
                  cx - int(120*scale) + wheel_r, wheel_y + wheel_r], fill=white)
    # Right wheel
    draw.ellipse([cx + int(155*scale) - wheel_r, wheel_y - wheel_r, 
                  cx + int(155*scale) + wheel_r, wheel_y + wheel_r], fill=white)
    
    # Plus sign inside cart
    plus_cx = cx + int(30 * scale)
    plus_cy = cy + int(20 * scale)
    plus_len = int(42 * scale)
    plus_w = int(30 * scale)
    # Vertical
    draw.line([(plus_cx, plus_cy - plus_len), (plus_cx, plus_cy + plus_len)], fill=white, width=plus_w)
    # Horizontal  
    draw.line([(plus_cx - plus_len, plus_cy), (plus_cx + plus_len, plus_cy)], fill=white, width=plus_w)
    # Round the plus ends
    pr = plus_w // 2
    for p in [(plus_cx, plus_cy - plus_len), (plus_cx, plus_cy + plus_len),
              (plus_cx - plus_len, plus_cy), (plus_cx + plus_len, plus_cy)]:
        draw.ellipse([p[0]-pr, p[1]-pr, p[0]+pr, p[1]+pr], fill=white)
    
    # TOPLA text
    text = "TOPLA"
    text_size = int(110 * scale)
    try:
        font = ImageFont.truetype("arialbd.ttf", text_size)
    except:
        try:
            font = ImageFont.truetype("arial.ttf", text_size)
        except:
            font = ImageFont.load_default()
    
    text_y = int(size * 0.76)
    bbox = draw.textbbox((0, 0), text, font=font)
    text_w = bbox[2] - bbox[0]
    text_x = (size - text_w) // 2
    draw.text((text_x, text_y), text, fill=white, font=font)
    
    img.save(save_path, "PNG")
    print(f"Saved: {save_path}")
    return img


def create_foreground_icon(size=1024, save_path="app_icon_foreground.png"):
    """Adaptive icon foreground - transparent background"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Same cart but on transparent bg
    cx, cy = size // 2, size * 0.42
    scale = size / 1024.0
    line_w = int(36 * scale)
    white = (255, 255, 255, 255)
    r_cap = line_w // 2
    
    # Cart handle
    handle_start = (cx - int(250 * scale), cy - int(135 * scale))
    handle_end = (cx - int(200 * scale), cy - int(85 * scale))
    draw.line([handle_start, handle_end], fill=white, width=line_w)
    draw.ellipse([handle_start[0]-r_cap, handle_start[1]-r_cap, handle_start[0]+r_cap, handle_start[1]+r_cap], fill=white)
    
    # Cart body
    points_cart = [
        (cx - int(200 * scale), cy - int(85 * scale)),
        (cx - int(145 * scale), cy + int(82 * scale)),
        (cx + int(165 * scale), cy + int(82 * scale)),
        (cx + int(215 * scale), cy - int(45 * scale)),
        (cx - int(95 * scale), cy - int(45 * scale)),
    ]
    
    for i in range(len(points_cart) - 1):
        draw.line([points_cart[i], points_cart[i+1]], fill=white, width=line_w)
        p = points_cart[i]
        draw.ellipse([p[0]-r_cap, p[1]-r_cap, p[0]+r_cap, p[1]+r_cap], fill=white)
    p = points_cart[-1]
    draw.ellipse([p[0]-r_cap, p[1]-r_cap, p[0]+r_cap, p[1]+r_cap], fill=white)
    
    # Wheels
    wheel_r = int(28 * scale)
    wheel_y = cy + int(145 * scale)
    draw.ellipse([cx - int(100*scale) - wheel_r, wheel_y - wheel_r, 
                  cx - int(100*scale) + wheel_r, wheel_y + wheel_r], fill=white)
    draw.ellipse([cx + int(130*scale) - wheel_r, wheel_y - wheel_r, 
                  cx + int(130*scale) + wheel_r, wheel_y + wheel_r], fill=white)
    
    # Plus sign
    plus_cx = cx + int(25 * scale)
    plus_cy = cy + int(15 * scale)
    plus_len = int(38 * scale)
    plus_w = int(26 * scale)
    draw.line([(plus_cx, plus_cy - plus_len), (plus_cx, plus_cy + plus_len)], fill=white, width=plus_w)
    draw.line([(plus_cx - plus_len, plus_cy), (plus_cx + plus_len, plus_cy)], fill=white, width=plus_w)
    pr = plus_w // 2
    for p in [(plus_cx, plus_cy - plus_len), (plus_cx, plus_cy + plus_len),
              (plus_cx - plus_len, plus_cy), (plus_cx + plus_len, plus_cy)]:
        draw.ellipse([p[0]-pr, p[1]-pr, p[0]+pr, p[1]+pr], fill=white)
    
    # TOPLA text
    text = "TOPLA"
    text_size = int(95 * scale)
    try:
        font = ImageFont.truetype("arialbd.ttf", text_size)
    except:
        try:
            font = ImageFont.truetype("arial.ttf", text_size)
        except:
            font = ImageFont.load_default()
    
    text_y = int(size * 0.72)
    bbox = draw.textbbox((0, 0), text, font=font)
    text_w = bbox[2] - bbox[0]
    text_x = (size - text_w) // 2
    draw.text((text_x, text_y), text, fill=white, font=font)
    
    img.save(save_path, "PNG")
    print(f"Saved: {save_path}")
    return img


if __name__ == "__main__":
    import sys
    base = r"c:\Users\ibroh\OneDrive\Desktop\TOPLA.APP\topla_app\assets\icon"
    create_app_icon(1024, f"{base}\\app_icon.png")
    create_foreground_icon(1024, f"{base}\\app_icon_foreground.png")
    print("Done! Both icons created.")
