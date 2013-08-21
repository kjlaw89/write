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
using Gdk;

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
	public class ContextToolbar : Toolbar
	{
		Write.Window Window { get; private set; }
		MultiModeButton StyleButtons { get; private set; }
		Granite.Widgets.ModeButton JustifyButtons { get; private set; }
		Gtk.ComboBoxText FormatCombo { get; private set; }
		ComboMenu InsertCombo { get; private set; }
		
		private bool manualFormatChange = false;
	
 		/**
 		 * Initializes the main window toolbar for the application
 		 */
		public ContextToolbar(Window window)
		{
			base("context-toolbar");
			Window = window;
			
			setup_formatting_combo();
			setup_styles();
			setup_alignments();
			setup_insert_combo();
		}
		
		private void setup_styles()
		{			
			var boldLabel = new Gtk.Label("<b>B</b>");
			boldLabel.use_markup = true;
			boldLabel.name = "bold";
			boldLabel.tooltip_text = "Bold Selection";
			
			var italicLabel = new Gtk.Label("<i>i</i>");
			italicLabel.use_markup = true;
			italicLabel.name = "italic";
			italicLabel.tooltip_text = "Italicize Selection";
			
			var underlineLabel = new Gtk.Label("<u>u</u>");
			underlineLabel.use_markup = true;
			underlineLabel.name = "underline";
			underlineLabel.tooltip_text = "Underline Selection";
			
			var strikethroughLabel = new Gtk.Label("<s>s</s>");
			strikethroughLabel.use_markup = true;
			strikethroughLabel.name = "strikeThrough";
			strikethroughLabel.tooltip_text = "Strikethrough Selection";
			
			var superLabel = new Gtk.Label("<sup>s</sup>");
			superLabel.use_markup = true;
			superLabel.name = "superscript";
			superLabel.tooltip_text = "Superscript Selection";
			
			// Add all the labels to the styles multimode
			StyleButtons = new MultiModeButton();
			StyleButtons.append(boldLabel);
			StyleButtons.append(italicLabel);
			StyleButtons.append(underlineLabel);
			StyleButtons.append(strikethroughLabel);
			StyleButtons.append(superLabel);
			StyleButtons.mode_changed.connect(handle_style_change);
			
			add_left(StyleButtons);
		}
		
		private void setup_alignments()
		{
			try 
			{
				var justifyLeft = new Pixbuf.from_stream(Window.Resources.open_stream("/org/elementary/write/justify_left.png", GLib.ResourceLookupFlags.NONE));
				var justifyLeftImage = new Gtk.Image.from_pixbuf(justifyLeft);
				var justifyLeftButton = new Gtk.Button();
				justifyLeftButton.image = justifyLeftImage;
				justifyLeftButton.name = "justifyLeft";
				justifyLeftButton.tooltip_text = "Left Align";
			
				var justifyCenter = new Pixbuf.from_stream(Window.Resources.open_stream("/org/elementary/write/justify_center.png", GLib.ResourceLookupFlags.NONE));
				var justifyCenterImage = new Gtk.Image.from_pixbuf(justifyCenter);
				var justifyCenterButton = new Gtk.Button();
				justifyCenterButton.image = justifyCenterImage;
				justifyCenterButton.name = "justifyCenter";
				justifyCenterButton.tooltip_text = "Center Align";
			
				var justifyRight = new Pixbuf.from_stream(Window.Resources.open_stream("/org/elementary/write/justify_right.png", GLib.ResourceLookupFlags.NONE));
				var justifyRightImage = new Gtk.Image.from_pixbuf(justifyRight);
				var justifyRightButton = new Gtk.Button();
				justifyRightButton.image = justifyRightImage;
				justifyRightButton.name = "justifyRight";
				justifyRightButton.tooltip_text = "Right Align";
			
				var justify = new Pixbuf.from_stream(Window.Resources.open_stream("/org/elementary/write/justify.png", GLib.ResourceLookupFlags.NONE));
				var justifyImage = new Gtk.Image.from_pixbuf(justify);
				var justifyButton = new Gtk.Button();
				justifyButton.image = justifyImage;
				justifyButton.name = "justifyFull";
				justifyButton.tooltip_text = "Justify Align";
			
				JustifyButtons = new Granite.Widgets.ModeButton();
				JustifyButtons.append(justifyLeftButton);
				JustifyButtons.append(justifyCenterButton);
				JustifyButtons.append(justifyRightButton);
				JustifyButtons.append(justifyButton);
				JustifyButtons.mode_changed.connect(handle_alignment_change);
			
				add_left(JustifyButtons);
			}
			catch (Error error)
			{
				stdout.printf("Unable to load alignment images. " + error.message);
			}	
		}
		
		private void setup_insert_combo()
		{
			InsertCombo = new ComboMenu("Insert         ");  // ToDO: Use real CSS to pad this
			InsertCombo.append_text("Image");
			InsertCombo.append_text("Table");
			InsertCombo.item_selected.connect(handle_insert_change);
			
			add_right(InsertCombo);
		}
		
		private void setup_formatting_combo()
		{
			FormatCombo = new Gtk.ComboBoxText();
			FormatCombo.append_text("Normal Text");
			FormatCombo.append_text("Title");
			FormatCombo.append_text("Subtitle");
			FormatCombo.append_text("Header 1");
			FormatCombo.append_text("Header 2");
			FormatCombo.append_text("Header 3");
			FormatCombo.append_text("Pre-Format");
			FormatCombo.append_text("Quote");
			FormatCombo.active = 0;
			FormatCombo.changed.connect(handle_format_change);
			
			add_left(FormatCombo);
		}
		
		private void handle_format_change()
		{
			if (manualFormatChange)
			{
				manualFormatChange = false;
				return;
			}
		
			var Document = Window.View.Document;
			switch (FormatCombo.active)
			{
				case 0:
					Document.exec_command("formatBlock", false, "p");
					break;
				case 1:
					Document.exec_command("formatBlock", false, "H1");
					break;
				case 2:
					Document.exec_command("formatBlock", false, "h2");
					break;
				case 3:
					Document.exec_command("formatBlock", false, "h3");
					break;
				case 4:
					Document.exec_command("formatBlock", false, "h4");
					break;
				case 5:
					Document.exec_command("formatBlock", false, "h5");
					break;
				case 6:
					Document.exec_command("formatBlock", false, "blockquote");
					break;
				case 7:
					Document.exec_command("formatBlock", false, "pre");
					break;
			}
		}
		
		private void handle_style_change(Gtk.Widget widget)
		{
			var Document = Window.View.Document;
			Document.exec_command(widget.name, false, "null");
		}
		
		private void handle_alignment_change(Gtk.Widget widget)
		{
			var Document = Window.View.Document;
			Document.exec_command(widget.name, false, "null");
		}
		
		private void handle_insert_change(int index)
		{
			var Document = Window.View.Document;
			switch (index)
			{
				case 1:
					Document.exec_command("insertHTML", false, """<table><tr><td></td><td></td></tr><tr><td></td><td></td></tr></table>""");
					break;
				default:
					break;
			}
		}
		
		public void SelectFormat(string format)
		{
			int newActive = 0;
			switch (format)
			{
				case "p":
					newActive = 0;
					break;
				case "h1":
					newActive = 1;
					break;
				case "h2":
					newActive = 2;
					break;
				case "h3":
					newActive = 3;
					break;
				case "h4":
					newActive = 4;
					break;
				case "h5":
					newActive = 5;
					break;
				case "blockquote":
					newActive = 6;
					break;
				case "pre":
					newActive = 7;
					break;
				default:
					newActive = 0;
					break;
			}
			
			if (newActive != FormatCombo.active)
			{
				manualFormatChange = true;
				FormatCombo.active = newActive;
			}
		}
		
		public void SelectStyles(bool bold = false, bool italic = false, bool underline = false, bool strike = false, bool super = false)
		{
			StyleButtons.set_active(0, bold, false);
			StyleButtons.set_active(1, italic, false);
			StyleButtons.set_active(2, underline, false);
			StyleButtons.set_active(3, strike, false);
			StyleButtons.set_active(4, super, false);
		}
		
		public void SelectAlignment(int alignment)
		{
			JustifyButtons.selected = alignment;
		}
	}
}
