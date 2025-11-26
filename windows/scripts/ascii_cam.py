#!/usr/bin/env python3
"""
ASCII Webcam - Camtro
Real-time ASCII art from your webcam
"""

import os
import sys

import cv2

# ASCII characters from darkest to brightest
ASCII_CHARS = " .:-=+*#%@"


def resize_image(frame, new_width=120):
    """Resize image maintaining aspect ratio"""
    height, width = frame.shape[:2]
    aspect_ratio = height / width
    new_height = int(new_width * aspect_ratio * 0.55)  # 0.55 to account for char height
    return cv2.resize(frame, (new_width, new_height))


def grayscale(frame):
    """Convert to grayscale"""
    return cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)


def pixels_to_ascii(image):
    """Convert pixels to ASCII characters (grayscale only)"""
    ascii_str = ""
    for row in image:
        for pixel in row:
            # Map pixel value (0-255) to ASCII character
            # Convert pixel to int first to avoid overflow
            index = int(pixel) * len(ASCII_CHARS) // 256
            ascii_str += ASCII_CHARS[index]
        ascii_str += "\n"
    return ascii_str


def pixels_to_colored_ascii(image, original):
    """Convert pixels to colored ASCII characters with RGB"""
    ascii_str = ""
    height, width = image.shape

    for y in range(height):
        for x in range(width):
            # Get grayscale value for character selection
            gray_pixel = int(image[y, x])
            index = gray_pixel * len(ASCII_CHARS) // 256
            char = ASCII_CHARS[index]

            # Get RGB color from original image
            b, g, r = original[y, x]

            # ANSI escape code for RGB color: \033[38;2;R;G;Bm
            ascii_str += f"\033[38;2;{r};{g};{b}m{char}\033[0m"

        ascii_str += "\n"

    return ascii_str


def clear_screen():
    """Clear terminal screen"""
    os.system("cls" if os.name == "nt" else "clear")


def main():
    import argparse

    parser = argparse.ArgumentParser(description="ASCII Webcam - Camtro")
    parser.add_argument(
        "-c", "--color", action="store_true", help="Enable RGB colored ASCII"
    )
    parser.add_argument(
        "-w", "--width", type=int, default=120, help="ASCII width (default: 120)"
    )
    args = parser.parse_args()

    mode = "RGB Color" if args.color else "Grayscale"
    print(f"🎥 Starting Camtro ({mode} mode)...")
    print("Press Ctrl+C to quit\n")

    # Open webcam (0 is default camera)
    cap = cv2.VideoCapture(0)

    if not cap.isOpened():
        print("❌ Error: Could not open webcam!")
        print("\nTroubleshooting:")
        print("1. Make sure no other app is using the camera")
        print("2. Check if camera is enabled in Windows settings")
        print("3. Try running as administrator")
        return

    # Set camera properties for better performance
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
    cap.set(cv2.CAP_PROP_FPS, 30)

    print("✓ Camera connected!")
    print("Loading...")

    try:
        frame_count = 0
        while True:
            ret, frame = cap.read()

            if not ret:
                print("❌ Failed to grab frame")
                break

            # Flip horizontally to remove mirror effect
            frame = cv2.flip(frame, 1)

            # Process every frame for smooth experience
            frame_count += 1

            # Resize for ASCII
            resized = resize_image(frame, args.width)

            # Convert frame to ASCII
            if args.color:
                # For color mode, we need both grayscale and original
                resized_gray = grayscale(resized)
                ascii_art = pixels_to_colored_ascii(resized_gray, resized)
            else:
                # Grayscale mode
                gray = grayscale(resized)
                ascii_art = pixels_to_ascii(gray)

            # Clear and display
            clear_screen()
            print(f"🎥 CAMTRO - {mode} Mode (Press Ctrl+C to quit)")
            print("=" * (args.width + 20))
            print(ascii_art)
            print("=" * (args.width + 20))
            print(
                f"Frame: {frame_count} | Resolution: {frame.shape[1]}x{frame.shape[0]}"
            )

    except KeyboardInterrupt:
        print("\n\n✓ Camtro stopped")

    finally:
        cap.release()
        print("✓ Camera released")


if __name__ == "__main__":
    main()
