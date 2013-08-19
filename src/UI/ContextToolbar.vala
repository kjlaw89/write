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
		MultiModeButton FormatButtons { get; private set; }
		Granite.Widgets.ModeButton JustifyButtons { get; private set; }
	
 		/**
 		 * Initializes the main window toolbar for the application
 		 */
		public ContextToolbar(Window window)
		{
			base("context-toolbar");
			Window = window;
			
			setup_styles();
			setup_alignments();
		}
		
		private void setup_styles()
		{
			FormatButtons = new MultiModeButton();
			FormatButtons.mode_changed.connect(handle_format_change);
			
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
			FormatButtons.append(boldLabel);
			FormatButtons.append(italicLabel);
			FormatButtons.append(underlineLabel);
			FormatButtons.append(strikethroughLabel);
			FormatButtons.append(superLabel);
			
			add_left(FormatButtons);
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
			
			
				add_left(JustifyButtons);
				JustifyButtons.mode_changed.connect(handle_alignment_change);
			}
			catch (Error error)
			{
				stdout.printf("Unable to load alignment images. " + error.message);
			}	
		}
		
		private void handle_format_change(Gtk.Widget widget)
		{
			var Document = Window.View.Document;
			Document.exec_command(widget.name, false, "null");
		}
		
		private void handle_alignment_change(Gtk.Widget widget)
		{
			var Document = Window.View.Document;
			Document.exec_command(widget.name, false, "null");
		}
		
		public void SelectFormats(bool bold = false, bool italic = false, bool underline = false, bool strike = false, bool super = false)
		{
			FormatButtons.set_active(0, bold, false);
			FormatButtons.set_active(1, italic, false);
			FormatButtons.set_active(2, underline, false);
			FormatButtons.set_active(3, strike, false);
			FormatButtons.set_active(4, super, false);
		}
		
		public void SelectAlignment(int alignment)
		{
			JustifyButtons.selected = alignment;
		}
	}
}
