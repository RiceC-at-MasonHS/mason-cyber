from flask import Flask, render_template, jsonify
from flask_socketio import SocketIO, emit
import subprocess
import threading
import time

app = Flask(__name__)
socketio = SocketIO(app)

container_status = {"status": "Initializing..."}
container_id = None  # Store the container ID globally
process = None  # Store the subprocess for terminal interaction
input_buffer = ""  # Add a global input buffer


def spin_up_container():
    global container_status, container_id
    """
    `tail -f /dev/null` is a command that leaves the container running indefinitely.
    """
    try:
        container_status["status"] = "Starting container..."
        result = subprocess.run(
            ['docker', 'run', '-d', '--name', 'kali_container', 'kalilinux/kali-rolling', 'tail', '-f', '/dev/null'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )

        if result.returncode != 0:
            container_status["status"] = f"Error: {result.stderr}"
        else:
            container_id = result.stdout.strip()
            container_status["status"] = "Container is ready"
            app.logger.info(f"Container ID: {container_id}")
    except Exception as e:
        container_status["status"] = f"Exception: {str(e)}"


def stop_container():
    global container_id, process
    if container_id:
        subprocess.run(['docker', 'stop', container_id])
        subprocess.run(['docker', 'rm', container_id])
        app.logger.info(f"Container {container_id} stopped and removed.")
        container_id = None

    # Terminate the subprocess if running
    if process and process.poll() is None:
        process.terminate()
        process = None


@app.route('/spin-up-kali', methods=['GET'])
def spin_up_kali():
    global container_status
    container_status["status"] = "Initializing..."
    threading.Thread(target=spin_up_container).start()
    return render_template('loading.html')


@app.route('/container-status', methods=['GET'])
def container_status_route():
    return jsonify(container_status)

@socketio.on('test-event')
def handle_test_event(data):
    app.logger.info(f"Received test-event with data: {data}")
    emit('test-response', {'message': 'Test event received!'})

@socketio.on('connect')
def handle_connect():
    app.logger.info("Client connected via WebSocket.")


@socketio.on('disconnect')
def handle_disconnect():
    app.logger.info("Client disconnected from WebSocket.")
    stop_container()


@socketio.on('terminal-input')
def handle_terminal_input(data):
    """
    Handle complete commands from the terminal in the frontend and send them to the container.
    """
    global process
    app.logger.info(f"Raw command received: {repr(data)}")  # Log the raw input
    sanitized_data = data.replace('\r', '').strip()  # Remove all \r characters and strip whitespace
    app.logger.info(f"Sanitized command: {repr(sanitized_data)}")  # Log the sanitized command
    if process and process.poll() is None:  # Check if the subprocess is running
        try:
            process.stdin.write(sanitized_data + '\n')  # Ensure the command ends with \n
            process.stdin.flush()
            app.logger.info("Command successfully written to subprocess.")  # Log success
        except Exception as e:
            app.logger.error(f"Error writing to subprocess: {str(e)}")


def stream_terminal_output():
    """
    Stream the terminal output from the container to the frontend.
    """
    global process
    if process:
        app.logger.info("Streaming terminal output...")  # Log when streaming starts
        try:
            while True:
                output = process.stdout.readline()
                if output == '' and process.poll() is not None:
                    break
                if output:
                    formatted_output = output.replace('\n', '\r\n')  # Replace \n with \r\n
                    app.logger.info(f"Output: {formatted_output.strip()}")  # Log each line of output
                    socketio.emit('terminal-output', formatted_output)  # Emit the line to the frontend

                # Handle stderr as well
                error = process.stderr.readline()
                if error:
                    formatted_error = error.replace('\n', '\r\n')  # Replace \n with \r\n
                    app.logger.error(f"Error: {formatted_error.strip()}")
                    socketio.emit('terminal-output', formatted_error)
        except Exception as e:
            app.logger.error(f"Error streaming terminal output: {str(e)}")


@socketio.on('start-terminal', namespace='/')
def start_terminal():
    """
    Start a terminal session in the container and stream its output.
    """
    global process
    app.logger.info("Received 'start-terminal' event.")  # Add this log
    if container_id:
        try:
            # Start an interactive shell in the container
            process = subprocess.Popen(
                ['docker', 'exec', '-i', container_id, '/bin/bash'],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                encoding='utf-8'

            )
            app.logger.info("Started terminal process.")  # Add this log
            threading.Thread(target=stream_terminal_output, daemon=True).start()

            # Test: Write a command to the container immediately
            process.stdin.write("echo 'Hello from container'\n")
            process.stdin.flush()
        except Exception as e:
            app.logger.error(f"Error starting terminal: {str(e)}")
            emit('terminal-output', f"Error: {str(e)}")


if __name__ == '__main__':
    socketio.run(app, port=3000, debug=True, log_output=True)