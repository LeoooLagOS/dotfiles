```python
import serial
import time
import logging

# Standard Logging to Disk (Requirement) 
logging.basicConfig(filename='protocol_session.log', level=logging.INFO)

class SerialNode:
    def __init__(self, port_name):
        # 9600 Baud, 8N1 
        self.ser = serial.Serial(port=port_name, baudrate=9600, timeout=1)

    def stop_and_wait_sender(self, message):
        """Logic for Stop & Wait: Send 1 byte, wait for ACK."""
        for char in message:
            self.ser.write(char.encode())
            logging.info(f"SENT: {char}")
            
            ack_received = False
            while not ack_received:
                if self.ser.in_waiting > 0:
                    response = self.ser.read().decode()
                    if response == 'A': # ACK representation
                        ack_received = True
                        logging.info("ACK RECV")
            time.sleep(0.1)

    def xon_xoff_receiver(self, threshold=0.8):
        """Logic for XON/XOFF: Signal Stop at 80% buffer."""
        buffer = []
        capacity = 100 # Simulated small buffer for testing
        while True:
            if len(buffer) >= (capacity * threshold):
                self.ser.write(b'\x13') # XOFF [cite: 81]
                logging.warning("XOFF SENT: Buffer near limit")
                # Simulate processing
                time.sleep(2)
                buffer = [] 
                self.ser.write(b'\x11') # XON [cite: 81]
            
            if self.ser.in_waiting > 0:
                buffer.append(self.ser.read())
```