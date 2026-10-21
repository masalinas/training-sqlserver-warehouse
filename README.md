## Introducción
Prueba de concepto de como utilizar agentes(Antigravity) con OpenSpec(SDD) para crear un entorno para probar DDL y comandos T-SQL en un servidor de pruebas SQL Server corriendo en VirtualBox (Windows 11).

## Entorno
Antes de que los agentes comiencen a crear el entorno. Debemos de asegurarnos de desde el host(Linux) podemos acceder a la instancia de SQL Server corriendo en un Windows 11 virtualizado connectado al host en modo **NAT**

1. Debemos de añadir una regla de reenvío en nuestro VirtualBox para poder acceder al puerto 1433 en donde escucha SQL Server. Debemos parar la maquina VM y accedemos a Red -> Pestaña de nuestro Adaptador 1 -> Avanzada y dentro crear la regla tal como se ve en la captura:

  ![Regla Reenvio VirtualBox](/images/regla-reenvio-virtualbox.png)

  Esta regla permite que toda conexión al host 127.0.0.1(Host VirtualBox) puerto 1433 se reenvie al host 10.0.2.15(VM Windows 11) puerto 1433

2. Arrancamos la VM y ahor debemos crear una regla en el cortafuegos de Windows 11 para abrir el puerto 1433 de SQL Server hacia el exterior. Ejecutar como administrador en power shell este comando:

  ```shell
  New-NetFirewallRule -DisplayName "SQL Server 1433" -Direction Inbound -Protocol TCP -LocalPort 1433 -Action Allow -Profile Any
  ```

3. Ahora podemos chequear que llegamos desde el host al puerto 1433 de SQL Server:

  ```shell
  ss -ltnp | grep 1433
  LISTEN   0        10                  127.0.0.1:1433             0.0.0.0:*
  ```

Esto confirma que desde el host 127.0.0.1 vemos el puerto 1433 que realmente esta arrancado en la VM Windows 11

## Proyecto agentico
Ahora que ya podemos llegar a SQL Server desde el host creamos nuestro proyecto agentico con OpenSpec:

1. Creamos el working folder del Proyecto
  ```shell
  mkdir training-sqlserver-warehouse
  cd training-sqlserver-warehouse
  ```

2. Inicializamos OpenSpec(instalar OpenSpec si aun no esta instalado en tu equipo):
  ```shell
  openspec init
  ```

Esto instalará en nuestro proyectos los skills de OpenSpec para poder trabajar con SDD.

3. Instalamos MCP para conectarnos a SQL Server
  Antes de arrancar el agente debemos de instalar un MCP para que el agente se pueda conectar al Servidor SQL Server. Yo he escogido este MCP:

  [mssql_mcp_server](https://github.com/RichardHan/mssql_mcp_server)

  Para instalarlo debemos de clonar el proyecto y compilar el MCP en nuestra carpeta de proyecto git

  ```shell
  git clone https://github.com/RichardHan/mssql_mcp_server.git
  cd mssql_mcp_server
  python3.12 -m venv .venv
  source .venv/bin/activate
  pip install -e .
  ```
  En estos momentos el MCP esta compilado y listo para ser utilizado por nuestros agentes.

4. Configurar el servidor MCP para ser utilizado por nuestro agentes
  Ahora aque ya tenemos el MCP listo para ser utilizado por nuestro agente volvemos a la carpeta working folder de nuestro proyecto `training-sqlserver-warehouse`\

  Creamos el fichero `mcp_config.json` bajo la carpeta .agents creada anteriormente por OpenSpec, en este fichero configuramos el servidor MCP\

  **Vemos que hemos guardado a fuego usuario y clave del servidor virtual, en principio como es interno no accesible fuera del host, no es problema, pero seria aconsejable evitar esto**

  ```shell
  {
    "mcpServers": {
      "mssql": {
        "command": "/home/miguel/git/mssql_mcp_server/.venv/bin/python",
        "args": [
          "-m",
          "mssql_mcp_server"
        ],
        "env": {
          "MSSQL_SERVER": "localhost",
          "MSSQL_PORT": "1433",
          "MSSQL_DATABASE": "training",
          "MSSQL_USER": "sa",
          "MSSQL_PASSWORD": "!Thingtrack2010",
          "MSSQL_ENCRYPT": "false",
          "DB_SERVER": "localhost",
          "DB_PORT": "1433",
          "DB_NAME": "training",
          "DB_USER": "sa",
          "DB_PASSWORD": "!Thingtrack2010"
        }
      }
    }
  }
  ```

  Como se puede ver hay muchas variables de entorno relacionadas con el Servidor SQLServer, asi como el accedo a nuestro MCP localizado y compilado en el repo `mssql_mcp_server`.

5. Arrancar agente IA
  Ahora ya tenemos todos los elementos necesarios para que el agente pueda trabajar con nuestro servidor SQL Server remoto en la windows 11 VM y ademas mediante la especificación SDD de OpenSpec. Ya solo nos queda arrancarlo.

  ```shell
  agy
  ```

  Solo tendremos que responder si para confiar en el repo y ya tendremos el agente listo para empezar a crear nuestra primer plan.

  Los planes y especificaciones creadas por el agente se encuentran grabadas en el fichero CHATS.md por si se quiere revisar las conversaciones entre el desarrollador y el aistente en todo el momento.

6. Arrancar agente IA
El desarrollo agentico se ha hecho através de 6 changes:

- Crear el fichero model.sql con todas las entidades de negocio según requisitos funcionales.
- Ejecutar el fichero model.sql creado contra la instancia remota SQL Server utilizando el MCP.
- Crear el fichero mocks.sql con todos los registros mocks según requisitos funcionales.
- Ejecutar el fichero mocks.sql insertando todos los registros mocks remotamente enla SQL Server utilizando el MCP.
- Crear el fichero queries.sql con todas las consultas según requisitos funcionales.
- Ejecutar el fichero queries.sql recuperando los registros remotamente en la SQL Server utilizando el MCP. El resultado sera volcado a un fichero results.md
