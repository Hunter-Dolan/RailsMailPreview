#
#  FBSidePanelViewController.rb
#  RailsMailPreview
#
#  Created by Fernando Barajas on 8/15/11.
#  Copyright 2011 Fernando Barajas. All rights reserved.
#

class FBSidePanelViewController < NSViewController
  attr_accessor :table
  attr_accessor :items
  attr_accessor :htmlview
  attr_accessor :plainview

  def saveNewMessage(mail)
    message = Message.new
    message.setMessage(mail)
    message.save

    self.items = Message.all
    self.table.reloadData
  end

  def items
    if @items.nil?
      self.items = Message.all
    else
      @items
    end
  end

  # - (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
  def numberOfRowsInTableView(aTableView)
    self.items.size
  end

  # - (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
  def tableView(tableView, rowViewForRow:row)
    FBSidePanelTableRowView.new
  end

  # - (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
  def tableView(tableView, viewForTableColumn:tableColumn, row:row)
    cell = tableView.makeViewWithIdentifier(tableColumn.identifier, owner:self)
    item = self.items.objectAtIndex(row)
    cell.from     = item.from
    cell.subject  = item.subject
    cell.date     = item.date
    cell.brief    = item.brief
    cell.selected = false
    cell
  end

  # - (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
  def tableView(tableView, heightOfRow:row)
    64 + 8
  end

  def tableViewSelectionDidChange(notification)
    row = self.table.selectedRow
    if row >= 0
      item = self.items.objectAtIndex(row)
      self.htmlview.loadHTMLString(generate_html_template(item))
      self.plainview.loadHTMLString(generate_text_template(item))
    end
  end

  def generate_html_template(item)
    self.generateTemplate("message.html", withItem:item)
  end

  def generate_text_template(item)
    self.generateTemplate("message.text", withItem:item)
  end

  def render_header(item)
    self.generateTemplate("_header.html", withItem:item)
  end

  def generateTemplate(template_name, withItem:item)
    template_path = NSBundle.mainBundle.pathForResource(template_name, ofType:"erb")
    template = File.open(template_path) {|f| f.read }
    rhtml = ERB.new(template)
    rhtml.result(binding)
  end
end
