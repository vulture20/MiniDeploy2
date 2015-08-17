using System;
using System.Collections.Generic;
using System.DirectoryServices;
using System.Drawing;
using System.Drawing.Text;
using System.IO;
using System.Linq;
using System.Management;
using System.Runtime.InteropServices;
using System.Text;

using System.Windows.Forms;

using MoonSharp.Interpreter;

namespace MiniDeploy2
{
    [MoonSharpUserData]
    class LuaFunctions
    {
        [DllImport("gdi32", EntryPoint = "AddFontResource")]
        public static extern int AddFontRessourceA(string lpFileName);
        [DllImport("user32.dll")]
        public static extern int SendMessage(int hWnd, uint Msg, int wParam, int lParam);
        [DllImport("kernel32.dll")]
        public static extern int WriteProfileString(string lpszSection, string lpszKeyName, string lpszString);

        public static bool is32Bit()
        {
            return (System.Environment.Is64BitOperatingSystem == false);
        }

        public static bool is64Bit()
        {
            return (System.Environment.Is64BitOperatingSystem == true);
        }

        public static bool setAdminPassword(string password) // set local admin password
        {
            string computerName = System.Environment.MachineName;
            string userName = "Administrator";
            DirectoryEntry directoryEntry = new DirectoryEntry(string.Format("WinNT://{0}/{1}", computerName, userName));

            try
            {
                directoryEntry.Invoke("SetPassword", password);
                return true;
            }
            catch
            {
                return false;
            }
        }

        public static bool addToDomain(string userName, string password, string domain) // add pc to domain
        {
            using (ManagementObject wmiObject = new ManagementObject(new ManagementPath("Win32_ComputerSystem.Name='" + System.Environment.MachineName + "'")))
            {
                try
                {
                    ManagementBaseObject inParams = wmiObject.GetMethodParameters("JoinDomainorWorkgroup");
                    inParams["Name"] = domain;
                    inParams["Password"] = password;
                    inParams["UserName"] = userName;
                    inParams["FJoinOptions"] = 3;
                    ManagementBaseObject outParams = wmiObject.InvokeMethod("JoinDomainOrWorkgroup", inParams, null);
                    if (!outParams["ReturnValue"].ToString().Equals("0")) return false;
                    return true;
                }
                catch
                {
                    return false;
                }
            }
        }

        public static bool startProcess(string fileName, string args) // starts a hidden process and evaluates the return code
        {
            System.Diagnostics.Process process = new System.Diagnostics.Process();
            process.StartInfo.FileName = fileName;
            process.StartInfo.Arguments = args;
            process.StartInfo.WindowStyle = System.Diagnostics.ProcessWindowStyle.Hidden;
            process.Start();
            while (!process.HasExited)
            {
                System.Windows.Forms.Application.DoEvents();
                System.Threading.Thread.Sleep(100);
            }
            if (process.ExitCode == 0) return true;
            else
                return false;
        }

        public static string getProgramPath() // returns the path to the windows program directory
        {
            return System.Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles) + "\\";
        }

        public static string getFontPath() // returns the path to the windows font directory
        {
            return System.Environment.GetFolderPath(Environment.SpecialFolder.Fonts) + "\\";
        }

        public static bool isDirectory(string path) // checks if given path is a directory
        {
            return Directory.Exists(path);
        }

        public static bool createDirectory(string path) // creates a directory
        {
            try
            {
                Directory.CreateDirectory(path);
            }
            catch
            {
                return false;
            }
            return true;
        }

        public static bool fileExists(string file) // checks if given file exists
        {
            return File.Exists(file);
        }

        public static bool fileCopy(string file, string destination) // copies a file to the given destination
        {
            try
            {
                File.Copy(file, destination);
            }
            catch
            {
                return false;
            }
            return true;
        }

        public static bool installFonts(string path) // installs all fonts from a given directory
        {
            bool ret = true;

            foreach (string file in Directory.EnumerateFiles(path, "*.ttf"))
            {
                string fileName = file.Split('\\')[file.Split('\\').Count() - 1];
                if (fileCopy(file, getFontPath() + fileName) != true) ret = false;
                if (AddFontRessourceA(getFontPath() + fileName) == 0) ret = false;
                SendMessage(0xffff, 0x001d, 0, 0);

                PrivateFontCollection fontCol = new PrivateFontCollection();
                fontCol.AddFontFile(getFontPath() + fileName);

                WriteProfileString("fonts", fontCol.Families[0].Name, fileName);
            }

            return ret;
        }
    }
}
