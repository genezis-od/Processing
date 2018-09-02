/*
StoveGuard Detector GUI for tests
*/

import controlP5.*;
ControlP5 cp5;
Chart myChart;

import processing.serial.*;    //  Подключаем библиотеку работы с СОМ-портом
Serial port;

// Constants
final int buffer_size = 4; 
final int start_receive_symbol = 49;

// Global variables 
int[]   rxbuf = new int[buffer_size];          // Массив-буфер для принятых байт
int     n=1;                         // Позиция в буфере
boolean recive=false;                // Статус приема
PFont   font;
int     blx = 48;                    // началопо Х
color   col = color(170,170,180);    // Основной цвет контура и заливки

void setup()
{
  size( 1024, 768 );                               // Размер окна Windows для отрисовки
 
  PFont font = loadFont("IrisUPCBold-48.vlw");    // Подключаем шрифт
  textFont(font,48);                              // Размер 16
 
  port = new Serial(this, "COM1", 115200);        // Подключаемся к СОМ-порту
  
  cp5 = new ControlP5(this);
  myChart = cp5.addChart("dataflow")
               .setPosition(50, 50)
               .setSize(600, 300)
               .setRange(-20, 20)
               .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
               .setStrokeWeight(1.5)
               .setColorCaptionLabel(color(40))
               ;

  myChart.addDataSet("incoming");
  myChart.setData("incoming", new float[100]);
}
 
void draw()
{
  background(10);                                 // Устанавливаем цвет фона
  textAlign(CENTER);    
  
  text("StoveGuard GUI",478,28);                   
   
  DrawCharts(blx, 74);  
  DrawBarGraphs(blx, 396);
  DrawFlags(blx, 482);
}
 
void DrawBarGraphs (int pos_x, int pos_y)
{
  // А тут нарисуем некий барграф, соответствующий значению принятого байта, чтоб место не пропадало
  
  fill(10);                                       // Устанавливаем фон
  stroke(200);                                    // Цвет контура
  rect(pos_x, pos_y, 255, 50);                         // Рисуем контур барграфа
  fill(255);                                      // Устанавливаем цвет барграфа
  rect(pos_x, pos_y, rxbuf[1], 50);                       // Рисуем барграф
  
}

void DrawFlags (int pos_x, int pos_y)
{
  text("PORTA",pos_x,pos_y);
  pickrect(rxbuf[1],blx,(pos_y+25));                       // Блок отрисовки состояний порта 
  
  text("PORTB",pos_x,(pos_y+84));
  pickrect(rxbuf[2],blx,(pos_y+108));                      // Блок отрисовки состояний порта 
  
  text("PORTC",pos_x,(pos_y+176));
  pickrect(rxbuf[3],blx,(pos_y+200));                      // Блок отрисовки состояний порта 
  
}

void pickrect(int bits, int blx, int bly)
{
  int blw = 28;                                    // ширина ячейки
  int blh = 28;                                    // высота ячейки
  int bls = 10;                                    // сдвиг между ячейками
  int mrg = 5;                                     // отступ от контура
  PFont font = loadFont("IrisUPCBold-48.vlw");    // Подключаем шрифт
  textFont(font,24);                               // Размер шрифта 24
  
  noFill();                                        // Только контур
  stroke(col);
  
  for(int i=0; i<8; i++){                          // Рисуем контуры квадратов и текст
    text(i,blx+(blw+bls)*i+blw/4,bly-mrg);
    rect(blx+(blw+bls)*i, bly, blw, blh,mrg*2);    
  }
  
  noStroke();                                      // Только заливка
  fill(col);
  
  for(int i = 0; i<8; i++){                        // Рисуем внутреннюю часть если соответствующий бит равен [1]
    if((bits & 0x80)==0x80){
      rect(blx+mrg+(blw+bls)*i+0.5, bly+mrg+0.5, blw-mrg*2, blh-mrg*2,mrg);                       
    }
  bits = bits <<1;
  }
}

void DrawCharts (int pos_x, int pos_y)
{
  //background(200);
  // unshift: add data from left to right (first in)
  //myChart.unshift("incoming", (sin(frameCount*0.1)*20));
  
  // push: add data from right to left (last in)
  myChart.push("incoming", (sin(frameCount*0.1)*20));
}
 
void serialEvent(Serial p)
{
  if(!recive){
    if(p.read() == start_receive_symbol)recive = true;                 // Сравниваем с "ключем" начала передачи. 
  }else{                                           
   if(n < (buffer_size-1)){n++;}else{n=1;recive=false;}            // Если передача начата и мы еще не все выгребли
   rxbuf[n] = p.read();                            // Считываем принятый байт из порта
  }
}
