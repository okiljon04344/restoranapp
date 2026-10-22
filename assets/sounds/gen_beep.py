import wave, struct, math
sample_rate = 44100
duration = 0.6
num_samples = int(sample_rate * duration)
filename = 'assets/sounds/notification.wav'
with wave.open(filename, 'w') as f:
    f.setnchannels(1)
    f.setsampwidth(2)
    f.setframerate(sample_rate)
    frames = []
    for i in range(num_samples):
        t = i / sample_rate
        envelope = min(1.0, t * 20) * max(0.0, 1.0 - (t / duration) * 0.7)
        tone = math.sin(2 * math.pi * (880 if t < 0.3 else 1100) * t)
        frames.append(struct.pack('<h', int(envelope * tone * 28000)))
    f.writeframes(b''.join(frames))
print('Created', filename)
