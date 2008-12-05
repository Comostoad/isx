﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace ISXEVE_Bot_Framework
{
    class Logging
    {
        /* Static instance */
        private static Logging _instance = new Logging();

        /* Internal static event for logging */
        internal static event EventHandler<LogMessageEventArgs> LogMessage;

        /* Private class, can only be instanced by itself */
        private Logging()
        {
            /* Attach our file logging to the logging event */
            LogMessage += new EventHandler<LogMessageEventArgs>(Logging_LogMessage);
        }

        /* Log the message to a file */
        /* If I can't create or open a file, detach this method from the handler and log an error so that
         * anything else reading log messages (Form displaying them, for example) can read the error */
        void Logging_LogMessage(object sender, LogMessageEventArgs e)
        {
            try
            {
                /* Get a temporary file stream to the log file */
                using (FileStream fs = new FileStream(String.Format("{0}\\{1}", InnerSpaceAPI.InnerSpace.Path, ".NET Programs\\ISXEVE_Bot_Framework_Log.txt"),
                    FileMode.OpenOrCreate))
                {
                    /* Use the temporary file stream to get a stream writer */
                    using (StreamWriter sw = new StreamWriter(fs))
                    {
                        /* Format our log message */
                        string logMessage = String.Format("{0}: {1}: {2}", System.DateTime.Now.ToShortTimeString(),
                            sender, e.Message);
                        /* Write a new line to the logfile through our stream */
                        sw.WriteLine(logMessage);
                        sw.Close();
                    }
                    fs.Close();
                }
            }
                /* If we can't open or create the file, detach the file logging from logging.
                 * UI logging can still successfully occur */
            catch (Exception ex)
            {
                /* Do the actual removing of the target from the event */
                LogMessage -= new EventHandler<LogMessageEventArgs>(LogMessage);
                /* Log that our shit fucked up */
                OnLogMessage(_instance, "Couldn't write to file stream: " + ex.Message);
            }
        }

        /* Fire off the LogMessage event */
        public static void OnLogMessage(object sender, string message)
        {
            /* If our event has targets */
            if (LogMessage != null)
                /* Fire the event */
                LogMessage(sender, new LogMessageEventArgs(message));
        }
    }

    /* EventArgs class for our log event */
    internal class LogMessageEventArgs : EventArgs
    {
        public string Message { get; set; }

        public LogMessageEventArgs(string message)
        {
            Message = message;
        }
    }
}
