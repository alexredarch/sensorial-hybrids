import cv2
from picamera2 import Picamera2
import numpy as np
from pydub import AudioSegment
from pydub.generators import Sine
from pydub.playback import _play_with_simpleaudio as play

# Expanded scales for A, B, and L channels
color_keys_a = ['C2', 'D2', 'E2', 'F2', 'G2', 'A2', 'B2', 'C3', 'D3', 'E3', 'F3', 'G3', 'A3', 'B3', 'C4']
color_keys_b = ['A2', 'B2', 'C3', 'D3', 'E3', 'F3', 'G3', 'A3', 'B3', 'C4', 'D4', 'E4', 'F4', 'G4', 'A4']

# Lightness keys now span a wide range of pitches (C1 to C6)
lightness_keys = [
    'C1', 'D1', 'E1', 'F1', 'G1', 'A1', 'B1',  # Very low
    'C2', 'D2', 'E2', 'F2', 'G2', 'A2', 'B2',
    'C3', 'D3', 'E3', 'F3', 'G3', 'A3', 'B3',
    'C4', 'D4', 'E4', 'F4', 'G4', 'A4', 'B4',
    'C5', 'D5', 'E5', 'F5', 'G5', 'A5', 'B5',
    'C6'  # Very high
]

# Cache for precomputed sounds
sound_cache = {}

def lab_to_key(value, channel_min=-128, channel_max=127, scale=None):
    normalized_value = (value - channel_min) / (channel_max - channel_min)
    index = int(normalized_value * (len(scale) - 1))
    return scale[max(0, min(index, len(scale) - 1))]

def generate_smooth_sound(pitch, duration, volume=-20):
    if (pitch, duration, volume) in sound_cache:
        return sound_cache[(pitch, duration, volume)]
    
    pitch_to_freq = {
        'C1': 32.70, 'D1': 36.71, 'E1': 41.20, 'F1': 43.65, 'G1': 49.00, 'A1': 55.00, 'B1': 61.74,
        'C2': 65.41, 'D2': 73.42, 'E2': 82.41, 'F2': 87.31, 'G2': 98.00, 'A2': 110.00, 'B2': 123.47,
        'C3': 130.81, 'D3': 146.83, 'E3': 164.81, 'F3': 174.61, 'G3': 196.00, 'A3': 220.00, 'B3': 246.94,
        'C4': 261.63, 'D4': 293.66, 'E4': 329.63, 'F4': 349.23, 'G4': 392.00, 'A4': 440.00, 'B4': 493.88,
        'C5': 523.25, 'D5': 587.33, 'E5': 659.25, 'F5': 698.46, 'G5': 783.99, 'A5': 880.00, 'B5': 987.77,
        'C6': 1046.50
    }
    base_frequency = pitch_to_freq.get(pitch, 261.63)
    sine_wave = Sine(base_frequency).to_audio_segment(duration=duration)
    sound = sine_wave.fade_in(int(duration * 0.2)).fade_out(int(duration * 0.2)) + volume
    sound_cache[(pitch, duration, volume)] = sound
    return sound

def process_live_camera(frame_duration=500, overlap=400):
    picam2 = Picamera2()
    
    # Create and configure the camera for RGB capture
    preview_config = picam2.create_preview_configuration(main={"format": "RGB888", "size": (640, 480)})
    picam2.configure(preview_config)
    picam2.start()

    try:
        while True:
            frame = picam2.capture_array()

            # Extract the center patch
            height, width, _ = frame.shape
            center_y, center_x = height // 2, width // 2
            half_patch_size = 50
            center_patch = frame[
                center_y - half_patch_size:center_y + half_patch_size,
                center_x - half_patch_size:center_x + half_patch_size
            ]

            # Convert to LAB color space
            lab_patch = cv2.cvtColor(center_patch, cv2.COLOR_RGB2LAB)
            avg_lab = np.mean(lab_patch, axis=(0, 1))
            l_value, a_value, b_value = avg_lab[0], avg_lab[1], avg_lab[2]

            # Map LAB channels to musical notes
            pitch_a = lab_to_key(a_value, -128, 127, scale=color_keys_a)
            pitch_b = lab_to_key(b_value, -128, 127, scale=color_keys_b)
            pitch_l = lab_to_key(l_value, 0, 100, scale=lightness_keys)

            # Generate sounds
            sound_a = generate_smooth_sound(pitch_a, frame_duration)
            sound_b = generate_smooth_sound(pitch_b, frame_duration)
            sound_l = generate_smooth_sound(pitch_l, frame_duration)
            frame_sound = sound_a.overlay(sound_b).overlay(sound_l)

            # Overlap and play sound
            play(frame_sound.overlay(frame_sound, gain_during_overlay=-5))
            print(f"Frame LAB Values: L={l_value:.2f}, A={a_value:.2f}, B={b_value:.2f}")
            print(f"Pitches: A={pitch_a}, B={pitch_b}, L={pitch_l}")


    except KeyboardInterrupt:
        print("Live processing stopped by user.")

    finally:
        picam2.stop()

if __name__ == "__main__":
    process_live_camera()
