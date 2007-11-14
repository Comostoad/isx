using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using EVE.ISXEVE;
using LavishVMAPI;
using InnerSpaceAPI;
using LavishScriptAPI;

namespace ISXEVEDotNet
{

    public sealed class Globals
    {
        public static readonly Globals Instance = new Globals();
        
        public EVE.ISXEVE.Me Me = new EVE.ISXEVE.Me();
        public EVE.ISXEVE.Extension Ext = new EVE.ISXEVE.Extension();
        
        private Globals() {}
    }
    
    public partial class Form1 : System.Windows.Forms.Form
    {
        Globals Globals = Globals.Instance;

        public Form1()
        {
            InitializeComponent();
            using (new FrameLock(true))
            {
                NameLabel.Text = "Your character's name is " + Globals.Me.Name;
            }
        }

        private void button1_Click(object sender, EventArgs e)
        {
            using (new FrameLock(true))
            {
                NameLabel.Text = "Your active ship has " + Globals.Me.Ship().HighSlots + " high slots.";
            }
            button1.Visible = false;
            button2.Visible = true;
        }

        private void button2_Click(object sender, EventArgs e)
        {
            using (new FrameLock(true))
            {
                NameLabel.Text = "Your active ship has " + Globals.Me.Ship().MediumSlots + " medium slots.";
            }
            button2.Visible = false;
            button3.Visible = true;
        }

        private void button3_Click(object sender, EventArgs e)
        {
            using (new FrameLock(true))
            {
                NameLabel.Text = "Your active ship has " + Globals.Me.Ship().LowSlots + " low slots.";
            }
            button3.Visible = false;
            button4.Visible = true;
        }

        private void button4_Click(object sender, EventArgs e)
        {
            using (new FrameLock(true))
            {
                if (Globals.Me.InStation)
                {
                    NameLabel.Text = "Undocking...";
                    Globals.Ext.EVE().Execute(ExecuteCommand.CmdExitStation);
                }
                else
                {
                    NameLabel.Text = "You are in space.";
                }
            }

            button4.Visible = false;
            button1.Visible = true;
        }
    }
}