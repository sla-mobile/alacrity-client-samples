using System;
using System.Collections;
using System.Globalization;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Reflection;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Net.Security;
using System.Security.Authentication;

namespace dotnet_client
{
	public class MainClass
	{
		private static Uri baseUrl = new Uri ("https://sandbox.api.sla-alacrity.com");
		private static string sandboxUrl = baseUrl + "1.0/";
		
		// Enabling this header will cause server to log detailed request statistics. you should only enable
		// this if requested by the Alacrity team when troubleshooting, otherwise you will see a performance
		// hit.
		private static bool traceHeaderEnabled = false;
		
		// Note that MSISDNs must be passed using URI format.
		private static string TEST_MSISDN = "tel:123456789";

		
		// This is the path to the Alacrity CA. Please adjust as necessary
		private static string privateRootCertFile = "../../sla-alacrity-ca-public.crt";

		
		// Test app retrieves customer transactions. Likely this wil
		public static void Main (string[] args)
		{
			InstallRootCA ();
			
			// This username / password pair should correspond to that set up in the partner portal. In addition
			// your IP address must be set up in the IP whitelist. Failure to do all of the above will mena you'll
			// be getting 401s back.
			CredentialCache credentials = Authorization ("insert username here", "insert password here");

			HttpWebRequest req = (HttpWebRequest)WebRequest.Create (sandboxUrl + TEST_MSISDN + "/transactions");
			req.Accept = "application/json";
			req.Credentials = credentials;			
			if (traceHeaderEnabled)
			  req.Headers.Add("x-alacrity-log", "net-demo");

			Console.WriteLine ("Requesting transaction history for MSISDN {0} via {1}", TEST_MSISDN, req.RequestUri.ToString ());
			
			try {
				WebResponse resp = req.GetResponse ();
				Stream stream = resp.GetResponseStream ();
				StreamReader sr = new StreamReader (stream, Encoding.UTF8);
				string response = sr.ReadToEnd ();
				Console.WriteLine (response);
			} catch (System.Net.WebException ex) {
				HttpWebResponse resp = (HttpWebResponse)ex.Response;
				Console.WriteLine ("error response = {0}", resp.ToString ());
				Console.WriteLine("headers:\n{0}", resp.Headers.ToString());
				
				Stream stream = resp.GetResponseStream ();
				StreamReader sr = new StreamReader (stream, Encoding.UTF8);
				string output = sr.ReadToEnd ();
				if (resp.StatusCode == HttpStatusCode.NotFound) {
					Console.WriteLine ("   ... customer not found, this is expected for this sample\n{0}", output);	
				} else {
				    Console.WriteLine ("   ... caught unexpected exception.Body = \n{0}", output);
					throw ex;
				}

			}
		}
		
		private static void InstallRootCA ()
		{
			X509Store store = new X509Store (StoreName.Root, StoreLocation.CurrentUser);
			store.Open (OpenFlags.ReadWrite);
			X509Certificate2 certificate = new X509Certificate2 (privateRootCertFile);
			store.Add (certificate);
		}
		
		static CredentialCache Authorization (string username, string password)
		{
			CredentialCache cache = new CredentialCache ();
			NetworkCredential nc = new NetworkCredential ();
			nc.UserName = username;
			nc.Password = password;
			nc.Domain = String.Empty;
			cache.Add (baseUrl, "Basic", nc);
			return cache;
		}
		
	}
}
	
