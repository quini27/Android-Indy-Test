/* Ejemplo de sketch para conectar a la placa Nodemcu o Wemos a una dirección de IP fija en vez de una dirección dinámica
Para eso son necesarias las informaciones
  Dirección IPv4: 192.168.0.12
  Máscara de Sub-red IPv4: 255.255.255.0
  Gateway Padrón IPv4: 192.168.0.1
Las mismas pueden ser obtenidas en el Painel de Controle\Rede e Internet\Central de Rede e Compartilhamento
Nome da rede Wifi / botón Detalhes

Este programa prueba la aplicación Delphi que usa IndyClient para se comunicar.
La aplicación permite comunicarse con el dispositivo IoT, enviar un string que es impreso en el monitor serial, y recibe 
mensajes enviados por el servidor IoT tal como el estado del botón.
*/

// Esta es la librería para utilizar las funciones de red del ESP8266
#include <ESP8266WiFi.h> 

const char* ssid = "Helena ";       //variable que almacena el nombre de la red wifi a la que el nodemcu se va a conectar
const char* password = "cenoura04"; //variable que almacena la seña de la red wifi donde el nodemcu se va a conectar
 
//DEFINICIÓN DE IP FIJO PARA EL NODEMCU
  IPAddress ip(192,168,0,200);    //(192,168,0,200);     //COLOQUE UNA FRANJA DE IP DISPONIBLE EN SU ROTEADOR. Ej: EX: 192.168.1.110 **** ESO VARÍA, EN MI CASO ES: 192.168.0.200
  IPAddress gateway(192,168,0,1);  //(192,168,0,1);  //GATEWAY DE CONEXIÓN (ALTERE PARA EL GATEWAY DE SU ROTEADOR)
  IPAddress subnet(255,255,255,0); //MASCARA DE RED
 
   //uso el led y el boton, entrada digital GPIO 0 y salida digital GPIO 2
  #define LED_BUILTIN 2
  #define BUTTON_BUILTIN 0

  //Puerto (dejar en 80 por defecto)
  //variables servidor y cliente
  WiFiServer servidor(100);
  WiFiClient cliente;

////////////////////////////////////////////////////////////////////////////
void setup() {
  // put your setup code here, to run once:
  //establece las entradas/salidas
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(BUTTON_BUILTIN,INPUT);
  
  //inicia comunicación serie con el monitor
  Serial.begin(115200);
  delay(50);

  //manda al monitor serie el nombre de la red a la cual se conectará
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  /* Configuramos el ESP8266 como estación WiFi y no como punto de acceso. 
   *  Si no lo hacemos  se configurará como cliente y punto de acceso al mismo tiempo */

   WiFi.mode(WIFI_STA); // Modo estación WiFi

  // Conectamos a la red WiFi
  WiFi.begin(ssid, password);
  WiFi.config(ip, gateway, subnet); //PASSA OS PARÂMETROS PARA A FUNÇÃO QUE VAI SETAR O IP FIXO

  // Esperamos a que estemos conectados a la red WiFi
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  // Iniciar el servidor
  servidor.begin();
  Serial.println("Se ha iniciado el servidor");
  Serial.println("");
  Serial.println("WiFi connected"); 
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP()); // Mostramos la IP que en este caso debe ser fija
  Serial.println("");
  
  // print the received signal strength:
  long rssi = WiFi.RSSI();
  Serial.print("signal strength (RSSI):");
  Serial.print(rssi);
  Serial.println(" dBm");

}


byte value=LOW;   //estado del LED
  

void loop() {
  // put your main code here, to run repeatedly:
  // listen for incoming clients
  cliente = servidor.available();
  if (cliente) {
    Serial.println("new client");
    cliente.println("Welcome client");
    while (cliente.connected()) {
              String request = cliente.readString(); //Until('\r');   //Hace la lectura del Cliente.
              if (request!='\0') Serial.println(request);     //si hay pedido, lo escribe en el monitor serial.
           
              // Operación del pedido
              if (request.indexOf("/LED=ON") != -1)  {
                    digitalWrite(LED_BUILTIN, LOW); // Si el pedido es LED=ON, enciende el LED
                    value = LOW;
                    cliente.println("led ligado");}
              if (request.indexOf("/LED=OFF") != -1)  {
                    digitalWrite(LED_BUILTIN, HIGH); // Si el pedido  es LED=OFF, apaga el LED
                    value = HIGH;
                    cliente.println("led desligado");}
              if (request.indexOf("/STATEBUTTON") != -1){
                    int estado = digitalRead(BUTTON_BUILTIN);               //le el estado del boton
                    if (estado) {
                      //Serial.println("botão não pressionado");
                      cliente.println("botão não pressionado");}            //y lo envia al cliente
                    else {
                      //Serial.println("botão pressionado");
                      cliente.println("botão pressionado");}
              }
              //cliente.println("message in a bottle");
              //cliente.printf("Estado do botão: %d",estado);
              if (request.indexOf("/STOPCLIENT") != -1) cliente.stop();     //pedido para desconectar el cliente

              if (Serial.available()>0){                                    //envia al cliente um string ingresado por el monitor serie
                String messerver=Serial.readString();
                cliente.println(messerver);
               }
    }
 }
}
