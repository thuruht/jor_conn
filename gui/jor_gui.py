#!/usr/bin/env python3
import sys
import subprocess
import os
from PyQt6.QtWidgets import (QApplication, QMainWindow, QWidget, QVBoxLayout,
                             QHBoxLayout, QPushButton, QLabel, QComboBox,
                             QTextEdit, QMessageBox, QFrame)
from PyQt6.QtCore import QTimer, Qt
from PyQt6.QtGui import QFont, QIcon

class JorGui(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Jor-Conn Manager")
        self.resize(600, 500)

        # Main Layout
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        layout = QVBoxLayout(central_widget)

        # Title
        title_label = QLabel("Jor-Conn Network Manager")
        title_label.setFont(QFont("Arial", 16, QFont.Weight.Bold))
        title_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(title_label)

        # Status Section
        self.status_text = QTextEdit()
        self.status_text.setReadOnly(True)
        self.status_text.setStyleSheet("background-color: #2b2b2b; color: #00ff00; font-family: Monospace;")
        layout.addWidget(QLabel("System Status:"))
        layout.addWidget(self.status_text)

        # Refresh Status Button
        refresh_btn = QPushButton("Refresh Status")
        refresh_btn.clicked.connect(self.refresh_status)
        layout.addWidget(refresh_btn)

        # Controls Section (Frame)
        controls_frame = QFrame()
        controls_frame.setFrameShape(QFrame.Shape.StyledPanel)
        controls_layout = QVBoxLayout(controls_frame)

        # Connection Control
        conn_layout = QHBoxLayout()
        conn_layout.addWidget(QLabel("Profile:"))
        self.profile_combo = QComboBox()
        self.load_profiles()
        conn_layout.addWidget(self.profile_combo)

        connect_btn = QPushButton("Connect")
        connect_btn.setStyleSheet("background-color: #4CAF50; color: white; font-weight: bold;")
        connect_btn.clicked.connect(self.connect_profile)
        conn_layout.addWidget(connect_btn)
        controls_layout.addLayout(conn_layout)

        # Proxy Control
        proxy_layout = QHBoxLayout()
        self.proxy_on_btn = QPushButton("Proxy ON")
        self.proxy_on_btn.clicked.connect(lambda: self.toggle_proxy("on"))
        proxy_layout.addWidget(self.proxy_on_btn)

        self.proxy_off_btn = QPushButton("Proxy OFF")
        self.proxy_off_btn.clicked.connect(lambda: self.toggle_proxy("off"))
        proxy_layout.addWidget(self.proxy_off_btn)
        controls_layout.addLayout(proxy_layout)

        # VNC Control
        vnc_btn = QPushButton("Launch VNC Viewer")
        vnc_btn.clicked.connect(self.launch_vnc)
        controls_layout.addWidget(vnc_btn)

        layout.addWidget(controls_frame)

        # Initial Status
        QTimer.singleShot(100, self.refresh_status)

    def run_command(self, cmd, sudo=False):
        if sudo:
            # Check if running as root, if not use pkexec
            if os.geteuid() != 0:
                cmd = ["pkexec"] + cmd

        try:
            result = subprocess.run(cmd, capture_output=True, text=True)
            return result.stdout + result.stderr
        except Exception as e:
            return str(e)

    def load_profiles(self):
        self.profile_combo.clear()
        # Look in local config first, then system
        paths = ["config/networks", "/etc/jor-conn/networks"]
        for path in paths:
            if os.path.isdir(path):
                try:
                    profiles = [f for f in os.listdir(path) if not f.startswith(".")]
                    self.profile_combo.addItems(profiles)
                    return
                except:
                    continue
        self.profile_combo.addItem("No profiles found")

    def refresh_status(self):
        # Determine jor path
        jor_path = "./jor" if os.path.isfile("./jor") else "jor"
        output = self.run_command([jor_path, "status"])
        self.status_text.setText(output)

    def connect_profile(self):
        profile = self.profile_combo.currentText()
        if not profile or profile == "No profiles found":
            QMessageBox.warning(self, "Error", "No profile selected")
            return

        jor_path = "./jor" if os.path.isfile("./jor") else "/usr/local/bin/jor"
        # We need to run this command in a terminal or handle password prompt via pkexec
        # Since 'jor connect' is interactive (progress bar), running it blindly might hide output
        # For GUI, we'll try pkexec and capture output
        self.status_text.setText(f"Connecting to {profile}...")
        QApplication.processEvents()

        output = self.run_command([jor_path, "connect", profile], sudo=True)
        self.status_text.setText(output)
        QMessageBox.information(self, "Connection", "Command finished. Check status log.")

    def toggle_proxy(self, state):
        jor_path = "./jor" if os.path.isfile("./jor") else "/usr/local/bin/jor"
        self.status_text.setText(f"Setting Proxy {state.upper()}...")
        QApplication.processEvents()

        output = self.run_command([jor_path, "proxy", state], sudo=True)
        self.status_text.setText(output)

    def launch_vnc(self):
        jor_path = "./jor" if os.path.isfile("./jor") else "jor"
        # VNC doesn't need sudo usually, but the script might check stuff
        # jor remote-vnc checks dependencies and runs vncviewer
        self.status_text.setText("Launching VNC...")
        QApplication.processEvents()
        subprocess.Popen([jor_path, "remote-vnc"])

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = JorGui()
    window.show()
    sys.exit(app.exec())
