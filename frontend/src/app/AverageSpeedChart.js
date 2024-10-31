// AverageSpeedChart.js
import React from 'react';
import { Line } from 'react-chartjs-2';
import { Chart, LineElement, CategoryScale, LinearScale, PointElement, Tooltip, Legend } from 'chart.js';

// Registrar los componentes necesarios de Chart.js
Chart.register(LineElement, CategoryScale, LinearScale, PointElement, Tooltip, Legend);

const AverageSpeedChart = ({ data }) => {
  const chartData = {
    labels: data.map((point) => point.time),
    datasets: [
      {
        label: 'Velocidad Promedio (Unidades/Segundo)',
        data: data.map((point) => point.averageSpeed),
        fill: false,
        backgroundColor: 'rgba(75,192,192,0.4)',
        borderColor: 'rgba(75,192,192,1)',
        tension: 0.1,
      },
    ],
  };

  const options = {
    responsive: true,
    scales: {
      x: {
        title: {
          display: true,
          text: 'Tiempo (Pasos de Simulación)',
        },
      },
      y: {
        title: {
          display: true,
          text: 'Velocidad Promedio',
        },
        beginAtZero: true,
      },
    },
    plugins: {
      legend: {
        position: 'top',
      },
      tooltip: {
        mode: 'index',
        intersect: false,
      },
    },
  };

  return <Line data={chartData} options={options} />;
};

export default AverageSpeedChart;
