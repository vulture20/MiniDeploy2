using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MoonSharp.Interpreter;

namespace MiniDeploy2
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            Script.GlobalOptions.Platform = new MoonSharp.Interpreter.Platforms.StandardPlatformAccessor();
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            DynValue ret;
            Configuration config = ConfigurationManager.OpenExeConfiguration(System.Reflection.Assembly.GetExecutingAssembly().Location);

            UserData.RegisterType<LuaFunctions>();
            Script script = new Script();
            DynValue obj = UserData.Create(new LuaFunctions());
            script.Globals.Set("deploy", obj);
            script.Options.DebugPrint = s => { MessageBox.Show(s); };
            
            try
            {
                ret = script.DoFile(Properties.Settings.Default.LUADefinitions);
            }
            catch (MoonSharp.Interpreter.SyntaxErrorException ex)
            {
                MessageBox.Show(ex.ToString());
            }
            
//            ret = script.DoString("return deploy.is64Bit();");
//            MessageBox.Show("is64Bit: " + ret.Number.ToString());

//            ret = script.DoString("print('openDeviceManager: ', openDeviceManager());");

            script.DoString("copyNetViewer('Z:');");
        }
    }
}
