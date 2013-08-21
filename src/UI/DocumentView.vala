/***
    Copyright (C) 2013-2014 Write Developers

    This program or library is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 3 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General
    Public License along with this library; if not, write to the
    Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301 USA.

    Authored by: KJ Lawrence <kjtehprogrammer@gmail.com>
***/

using Granite;
using Granite.Widgets;
using Gee;
using WebKit;

namespace Write
{
	/**
	 * Application Window for Write
	 * Initializes a window with an integrated toolbar
	 *
	 * This class will facilitate communications between all
	 * of the individual elements in the program through various
	 * methods and exposure of elements when necessary.
	 *
	 * Structure:
	 *	<Gtk.Window>
	 *	</Gtk.Window>
	 */
	public class DocumentView : WebView
	{
		Write.Window Window { get; private set; }
		public WebKit.DOM.Document Document { get { return get_dom_document(); } }
		public WebKit.DOM.HTMLHeadElement Head { get { return Document.head; } }
		public WebKit.DOM.HTMLElement Body { get { return Document.body; } }
		public WebKit.DOM.HTMLInputElement ZoomControl { get; private set; }
	
 		/**
 		 * Initializes the default web view using our template and scripts
 		 */
		public DocumentView(Window window)
		{
			Window = window;
		
			settings.enable_caret_browsing = true;
			settings.enable_developer_extras = true;
			settings.enable_default_context_menu = false;
			settings.enable_plugins = false;
			settings.enable_private_browsing = true;
			settings.enable_java_applet = false;
			
			load_string(Window.GetResourceAsString("/org/elementary/write/template.html"), "text/html", "UTF8", "");
			load_finished.connect(on_load);
			selection_changed.connect(handle_selection_changed);
		}
		
		/**
		 * Handles the initial load of WebKit
		 */
		private void on_load(WebFrame frame)
		{
			try
			{
				// Load in our styles
				var styleElement = Document.create_element("style");
				var styleText = Document.create_text_node(Window.GetResourceAsString("/org/elementary/write/document.css"));
				styleElement.set_attribute("type", "text/css");
				styleElement.append_child(styleText);
				Head.append_child(styleElement);
			
				// Load in our various scripts
				var jqueryElement = Document.create_element("script");
				var jqueryText = Document.create_text_node(Window.GetResourceAsString("/org/elementary/write/jquery.js"));
				jqueryElement.set_attribute("type", "text/javascript");
				jqueryElement.append_child(jqueryText);
				Head.append_child(jqueryElement);
			
				var sliderElement = Document.create_element("script");
				var sliderText = Document.create_text_node(Window.GetResourceAsString("/org/elementary/write/zoom.js"));
				sliderElement.set_attribute("type", "text/javascript");
				sliderElement.append_child(sliderText);
				Head.append_child(sliderElement);
			
				ZoomControl = Document.get_element_by_id("zoom_control") as DOM.HTMLInputElement;
				//ZoomControl.add_event_listener("change", (GLib.Callback)zoom, true, null);
				
				// Tell the document to go to do all edits with styles
				Document.exec_command("styleWithCSS", false, "true");
				Document.exec_command("enableInlineTableEditing", false, "true");
				Document.exec_command("enableObjectResizing", false, "true");
			}
			catch (Error error)
			{
				stdout.printf("Unable to load JavaScript resources. Write will not function properly. " + error.message);
			}
		}
		
		private void handle_selection_changed()
		{
			var Context = Window.ContextBar;
		
			bool bold = Document.query_command_state("Bold");
			bool italic = Document.query_command_state("Italic");
			bool underline = Document.query_command_state("Underline");
			bool strike = Document.query_command_state("Strikethrough");
			bool super = Document.query_command_state("Superscript");
			Context.SelectStyles(bold, italic, underline, strike, super);
			
			bool justifyLeft = Document.query_command_state("justifyLeft");
			bool justifyCenter = Document.query_command_state("justifyCenter");
			bool justifyRight = Document.query_command_state("justifyRight");
			bool justify = Document.query_command_state("justifyFull");
			
			if (justifyLeft)
				Context.SelectAlignment(0);
			else if (justifyCenter)
				Context.SelectAlignment(1);
			else if (justifyRight)
				Context.SelectAlignment(2);
			else if (justify)
				Context.SelectAlignment(3);
				
			string format = Document.query_command_value("FormatBlock");
			Context.SelectFormat(format);
		}
		
		/*private void zoom()
		{
			var view = DocumentView.Instance;
			string zoomAmount = view.ZoomControl.value;
			
			var elements = view.Document.get_elements_by_class_name("page");
			for (int i = 0; i < elements.length; i++)
			{
				try
				{
					var element = elements.item(i) as DOM.HTMLElement;
					var elementStyle = element.style;
					elementStyle.set_property("zoom", zoomAmount, "");
				}
				catch (Error error)
				{
					stdout.printf("Unable to resize page. " + error.message);
				}
			}
		}*/
	}
}
