'use client'
import { useRef, useState, useEffect } from "react";
import styles from "./page.module.css";


export default function Home() {
  let [location, setLocation] = useState("");
  let [boxes, setBoxes] = useState([]);
  let [robots, setRobots] = useState([]);
  let gridSize = 40;
  const running = useRef(null);

  let setup = () => {
    fetch("http://localhost:8000/simulations", {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ dim: [gridSize, gridSize], position_Boxes: 40, position_Robots: 5}) // Enviar número de círculos deseado
    }).then(resp => resp.json())
    .then(data => {
      setLocation(data["Location"]);
      const state = data["boxes"];
      setBoxes(state);
      setRobots(data["robots"]);
    });
  }

  const handleStart = () => {
    if (!location) return;
    running.current = setInterval(() => {
      fetch("http://localhost:8000" + location)
      .then(res => res.json())
      .then(data => {
        setBoxes(data["boxes"]);
        setRobots(data["robots"]);
      });
    }, 500);
  };

  const handleStop = () => {
    clearInterval(running.current);
  }

  // Función para dibujar la grilla
  const drawGrid = () => {
    const grid = [];
    for (let x = 0; x <= 40; x++) {
      grid.push(<line key={`v${x}`} x1={x * 20} y1={0} x2={x * 20} y2={800} stroke="lightgray" strokeWidth={0.5} />);
    }
    for (let y = 0; y <= 40; y++) {
      grid.push(<line key={`h${y}`} x1={0} y1={y * 20} x2={800} y2={y * 20} stroke="lightgray" strokeWidth={0.5} />);
    }
    return grid;
  }

  return (
    <main className={styles.main}>
      <div>
        <button onClick={setup}>Setup</button>
        <button onClick={handleStart}>Start</button>
        <button onClick={handleStop}>Stop</button>
      </div>
      <svg width="800" height="800" xmlns="http://www.w3.org/2000/svg" style={{backgroundColor:"white", border: "1px solid black"}}>
        {drawGrid()}
        {/* Dibujar círculos */}
        {boxes.map((box, index) => (
          <rect
          key={`box-${index}`}
          x={(box.pos[0] - 1) * 20}
          y={800 - (box.pos[1] * 20) - 20}
          width={20}
          height={20}
          fill={`rgb(255, ${255 - box.height * 50}, 0)`}
        />
        ))}
        {/* Dibujar robots */}
        {robots.map((robot, index) => (
          <rect
            key={`robot-${index}`}
            x={(robot.pos[0] - 1) * 20}
            y={800 - (robot.pos[1] * 20) - 20}
            width={20}
            height={20}
            fill={robot.has_box ? "blue" : "red"}
          />
        ))}
      </svg>
    </main>
  );
}