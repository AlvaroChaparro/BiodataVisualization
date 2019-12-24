import java.io.*;
import java.util.List;
import java.util.Arrays;

// Ajustar el tamaño de la ventana para que se pueda redimensionar

// From 0 to 1400 Grahps
// From 1400 to 1600 Numbers and Text
// Divided in 3: 0-300, 300-600, 600-900
int t;
int[] alpha = new int[3];
int ECG_signal, ECG_ave, ECG_old;
int SPO2_signal, SPO2_ave, SPO2_old;
int RPM_signal, RPM_ave, RPM_old;
int HR_num, SPO2_num, RPM_num;

// Listas y arrays de datos
float[] ecgArray;
float[] spo2Array;
float[] rpmArray;

// Lista de Numerics
ArrayList<Integer> ecgNumerics = new ArrayList();
ArrayList<Integer> spo2Numerics = new ArrayList();
ArrayList<Integer> rpmNumerics = new ArrayList();

PFont fontBold;
PFont fontNarrow;

// Lista temporal de apoyo 
ArrayList<Float> ecgRecords = new ArrayList();
ArrayList<Float> spo2Records = new ArrayList();
ArrayList<Float> rpmRecords = new ArrayList();

// Valores auxiliares
float scaling;
int point0, point1;
float minECG, minSPO2, minRPM;
float maxECG, maxSPO2, maxRPM;

// Colores
color[] palette;

void setup(){
  //fullScreen();
  
  // Al iniciar con la anchura/altura de la pantalla podemos
  // escalar haciar abajo sin errores
  //size(displayWidth,displayWidth);
  
  // Si escalamos el ancho por encima del original habra un
  // error de indexOutOfBounds
  size(1600,900);
  
  surface.setResizable(true);
  frameRate(125);
  
  // Cogemos los colres del archivo
  setpalette();
  
  // The font must be located in the sketch's 
  // "data" directory to load successfully
  fontBold = loadFont("Arial-BoldMT.vlw");
  fontNarrow = loadFont("ArialNarrow-Bold.vlw");
  
  // La capacidad de este array marca la resolucion
  // maxima horizontal que soporta el programa
  // No se puede estirar mas alla de la resolucion
  // de la pantalla
  // En un principio se reservaba el tamaño justo
  // pero con la introduccion del re-escalado surgian
  // problemas de overflow
  //ecgArray = new float[width*13/16];
  ecgArray = new float[displayWidth];
  //spo2Array = new float[width*13/16];
  spo2Array = new float[displayWidth];
  //rpmArray = new float[width*13/16];
  rpmArray = new float[displayWidth];
  
  maxECG = maxSPO2 = maxRPM = -99999;
  minECG = minSPO2 = minRPM = 99999;  
  
  // Apertura de archivos
  // 41,23,34 Gente en forma (60-77)
  // 22,18,28 Medio (77-90)
  // 01,05,07,24 Regulares (90-100)
  // 21,52,35 Arritmico (110+)
  File fileSignal = new File(dataPath("../dataset/bidmc_41_Signals.csv"));  
  File fileNumerics = new File(dataPath("../dataset/bidmc_41_Numerics.csv"));
  
  // ECG GRAPH

  try {
    // Archivo con datos de grafica ECG
    BufferedReader br = new BufferedReader(new FileReader(fileSignal));
    // Archivo con datos de Numerics
    BufferedReader br2 = new BufferedReader(new FileReader(fileNumerics));
    
    String line;
    // Columna a coger de Signals
    int index = 0;
    // Columna a coger de Numerics
    int index2 = 0;
    
    // Eleccion del index de columna de Signals
    line = br.readLine();
    String[] column = line.split(",");
    for (int i=0; i<column.length; i++){
      if (column[i].equals(" II")){
        // Columna donde esta el valor que queremos
        index = i;
      } 
    }
    
    // Eleccion del index de columna de Numerics
    line = br2.readLine();
    column = line.split(",");
    for (int i=0; i<column.length; i++){
      if (column[i].equals(" HR")){
        // Columna donde esta el valor que queremos
        index2 = i;
      } 
    }
    
    int current = 1;
    int control = 0;
    while ((line = br.readLine()) != null) {
      String[] values = line.split(",");
      // Añadir valores a la lista sin normalizar
      ecgRecords.add(float(values[index]));
      // Valor de control si cambia de segundo
      current = int(float(values[0]));
      // Si cambia el valor del tiempo al siguiente segundo
      if (current != control){
        if ((line = br2.readLine()) != null){
          values = line.split(",");
          ecgNumerics.add(int(values[index2]));
          control = current;
        }
      }else{
        if (ecgNumerics.size() > 0)
        ecgNumerics.add(ecgNumerics.get(ecgNumerics.size()-1));
      }
    }
    // Cerramos archivos
    br.close();
    br2.close();
  }catch (Exception e){
    print(e);
  }
 
  // Min/Max
  for (float num : ecgRecords){
    if(num < minECG) minECG = num;
    if(num > maxECG) maxECG = num;
  }
  
  // SPO2 GRAPH

  try {
    BufferedReader br = new BufferedReader(new FileReader(fileSignal));
    BufferedReader br2 = new BufferedReader(new FileReader(fileNumerics));
    
    String line;
    int index = 0;
    int index2 = 0;

    line = br.readLine();
    String[] column = line.split(",");
    for (int i=0; i<column.length; i++){
      if (column[i].equals(" PLETH")){
        index = i;
      } 
    }

    line = br2.readLine();
    column = line.split(",");
    for (int i=0; i<column.length; i++){
      if (column[i].equals(" SpO2")){
        // Columna donde esta el valor que queremos
        index2 = i;
      } 
    }

    int current = 1;
    int control = 0;
    while ((line = br.readLine()) != null) {
      String[] values = line.split(",");
      spo2Records.add(float(values[index]));

      current = int(float(values[0]));
      if (current != control){
        if ((line = br2.readLine()) != null){
          values = line.split(",");
          spo2Numerics.add(int(values[index2]));
          control = current;
        }
      }else{
        if (spo2Numerics.size() > 0)
        spo2Numerics.add(spo2Numerics.get(spo2Numerics.size()-1));
      }
    }
    br.close();
    br2.close();
  }catch (Exception e){
    print(e);
  }
  
  // Min/Max
  for (float num : spo2Records){
    if(num < minSPO2) minSPO2 = num;
    if(num > maxSPO2) maxSPO2 = num;
  }
  
  // RPM GRAPH

  try {
    BufferedReader br = new BufferedReader(new FileReader(fileSignal));
    BufferedReader br2 = new BufferedReader(new FileReader(fileNumerics));

    String line;
    int index = 0;
    int index2 = 0;

    line = br.readLine();
    String[] column = line.split(",");
    for (int i=0; i<column.length; i++){
      if (column[i].equals(" RESP")){
        index = i;
      } 
    }

    line = br2.readLine();
    column = line.split(",");
    for (int i=0; i<column.length; i++){
      if (column[i].equals(" RESP")){
        // Columna donde esta el valor que queremos
        index2 = i;
      } 
    }

    int current = 1;
    int control = 0;
    while ((line = br.readLine()) != null) {
      String[] values = line.split(",");
      rpmRecords.add(float(values[index]));

      current = int(float(values[0]));
      // Si cambia el valor del tiempo al siguiente segundo
      if (current != control){
        if ((line = br2.readLine()) != null){
          values = line.split(",");
          rpmNumerics.add(int(values[index2]));
          control = current;
        }
      }else{
        if (rpmNumerics.size() > 0)
        rpmNumerics.add(rpmNumerics.get(rpmNumerics.size()-1));
      }
    }
    br.close();
    br2.close();
  }catch (Exception e){
    print(e);
  }
  
  // Min/Max
  for (float num : rpmRecords){
    if(num < minRPM) minRPM = num;
    if(num > maxRPM) maxRPM = num;
  }
  
}

void draw(){
  //frame.setSize() 
  background(palette[0]);
  
  drawSensorData(1,ecgArray);
  //drawECG();
  drawECGNumbers();
  
  drawSensorData(2,spo2Array);
  //drawSPO2();
  drawSPO2Numbers();
  
  drawSensorData(3,rpmArray);
  //drawRPM();
  drawRPMNumbers();
  
  // Width graphs control
  t++;
  if (t>(width*13/16-1)) t=0;
}

  // Dibujamos los datos de los sensores
void drawSensorData(int file, float[] dataArray){
  // Cogemos los valores tal cual obtenidos del fichero
  switch(file){
    case 1:
      dataArray[t] = ecgRecords.get(0);
      ecgRecords.add(ecgRecords.remove(0));
      break;
      
    case 2:
      dataArray[t] = spo2Records.get(0);
      spo2Records.add(spo2Records.remove(0));
      break;
      
    case 3:
      dataArray[t] = rpmRecords.get(0);
      rpmRecords.add(rpmRecords.remove(0));
      break;
  }

  // Color de esta seccion
  fill(palette[file]);
  strokeWeight(3);
  
  for(int i=1; i<width*13/16; i++){
    // Escalamos los valores para ajustarnos al tamaño de pantalla
    switch(file){
      case 1:
        scaling = (ecgArray[i-1]-minECG)/(maxECG-minECG);
        point0 = int(height - (scaling*height/3*0.99) - height*2/3*0.99);
        scaling = (ecgArray[i]-minECG)/(maxECG-minECG);
        point1 = int(height - (scaling*height/3*0.99) - height*2/3*0.99);
        break;
      case 2:
        scaling = (spo2Array[i-1]-minSPO2)/(maxSPO2-minSPO2);
        point0 = int(height - (scaling*height/3*0.99) - height/3*0.99);
        scaling = (spo2Array[i]-minSPO2)/(maxSPO2-minSPO2);
        point1 = int(height - (scaling*height/3*0.99) - height/3*0.99);
        break;
      case 3:
        scaling = (rpmArray[i-1]-minRPM)/(maxRPM-minRPM);
        point0 = int(height - (scaling*height/3*0.99) - 5);
        scaling = (rpmArray[i]-minRPM)/(maxRPM-minRPM);
        point1 = int(height - (scaling*height/3*0.99) - 5);
        break;
    }

    // Dependiendo de por donde va el puntero t dibujamos cierta
    // parte de la animacion
    if(t+255>width*13/16 && i<((t+255)-width*13/16)){
      stroke(palette[file], alpha[file-1]);
      strokeWeight(3);
      if(dataArray[i]!=0)
      line(i-1,point0,i,point1);
      alpha[file-1]++;
    }else{
      if(i<=t){
        alpha[file-1]=0;
        if(dataArray[i]!=0)
          stroke(palette[file]);  
          strokeWeight(3);
          line(i-1,point0,i,point1);
        if(i==t-1)
          circle(i,point1,10);
      }
      if(i>t){
        stroke(palette[file], alpha[file-1]);
        strokeWeight(3);
        if(dataArray[i]!=0)
        line(i-1,point0,i,point1);
        alpha[file-1]++;
      }
    }    
  }
}

  // ECG Numbers
void drawECGNumbers(){
  HR_num = ecgNumerics.get(0);
  ecgNumerics.add(ecgNumerics.remove(0));
  
  textAlign(CENTER, CENTER);
  rectMode(CENTER);
  
  textFont(fontBold, ((width*3/16)+(height*4/18))*0.28-(100/height));
  print("\n");
  text(str(HR_num), width*14.5/16,height*4/18,width*3/16,height*2/9);
  
  textFont(fontNarrow, ((width*3/16)+(height*1/18))*0.11428);
  text(" ECG",width*14/16,height*1/18,width*1/16,height*1/9);
  
  textFont(fontBold, ((width*3/16)+(height*1/18))*0.08571);
  text("BPM ",width*15/16,height*1/18,width*1/16,height*1/9);
}

  // SPO2 Numbers
void drawSPO2Numbers(){
  
  SPO2_num = spo2Numerics.get(0);
  spo2Numerics.add(spo2Numerics.remove(0));

  textAlign(CENTER, CENTER);
  rectMode(CENTER);
  
  textFont(fontBold, ((width*3/16)+(height*4/18))*0.28);
  text(str(SPO2_num), width*14.5/16,height*10/18,width*3/16,height*2/9);
  
  textFont(fontNarrow, ((width*3/16)+(height*1/18))*0.11428);
  text(" SPO2",width*14/16,height*7/18,width*1/16,height*1/9);
  
  textFont(fontBold, ((width*3/16)+(height*1/18))*0.08571);
  text("%",width*15/16,height*7/18,width*1/16,height*1/9);
}

  // RPM Numbers
void drawRPMNumbers(){
  
  RPM_num = rpmNumerics.get(0);
  rpmNumerics.add(rpmNumerics.remove(0));
  
  textAlign(CENTER, CENTER);
  rectMode(CENTER);
  
  textFont(fontBold, ((width*3/16)+(height*4/18))*0.28);
  text(str(RPM_num), width*14.5/16,height*16/18,width*3/16,height*2/9);
  
  textFont(fontNarrow, ((width*3/16)+(height*1/18))*0.11428);
  text(" RESP",width*14/16,height*13/18,width*1/16,height*1/9);
  
  textFont(fontBold, ((width*3/16)+(height*1/18))*0.08571);
  text(" RPM",width*15/16,height*13/18,width*1/16,height*1/9);
}

// Metodo para cargar los colores desde un archivo
void setpalette() {
  String[] strings = loadStrings("../colors/palette.txt");
  palette = new color[strings.length];
  for (int p = 0; p<strings.length; p++) {
    palette[p] = color(unhex(strings[p]) | 0xff000000);
  }
}
