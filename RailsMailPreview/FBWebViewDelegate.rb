#
#  FBWebViewDelegate.rb
#  RailsMailPreview
#
#  Created by Fernando Barajas on 8/24/11.
#  Copyright 2011 Fernando Barajas. All rights reserved.
#

class FBWebViewDelegate
  # - (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
  def webView(webview, contextMenuItemsForElement:items, defaultMenuItems:defaultItems)
    if items
      if items['WebElementIsSelected'] && items['WebElementDOMNode'].class.to_s == "DOMText"
        selected_text = webview.selectedDOMRange.markupString.flattenHTML.to_s.strip
        if selected_text.size > 0
          newDefaultItem = defaultItems.select do |item|
            ( item.title =~ /^copy$/i || item.title.to_s =~ /Inspect/i )
          end
          
          if newDefaultItem
            return newDefaultItem
          end
        end
      end
    end

    if AppDelegate.development?
     defaultItems
    else
      newElements = defaultItems.select {|item| item.title =~ /Inspect/i }
      return newElements
    end
  end

  def webView(webview, createWebViewWithRequest:request)
    return nil
  end

  # - (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id < WebPolicyDecisionListener >)listener
  def webView(webview, decidePolicyNavigationAction:actionInfo, request:request,
              frame:webFrame, decisionListener:listener)
    listener.ignore
  end

  # - (void)webView:(WebView *)webView decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id < WebPolicyDecisionListener >)listener
  def webView(webview, decidePolicyForNewWindowAction:actionInfo,
                       request:request, newFrameName:frameName, decisionListener:listener)
    NSWorkspace.sharedWorkspace.openURL(request.URL)
    listener.ignore
  end

  # - (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
  def webView(webview, didStartProvisionalLoadForFrame:webFrame)
    requrl = webFrame.provisionalDataSource.request.URL
    if requrl.absoluteString =~ /^http:\/\//
      webFrame.stopLoading
      NSWorkspace.sharedWorkspace.openURL(requrl)
    end
  end

  #- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
  def webView(webview, didFinishLoadForFrame:webFrame)
    if @webScriptObjectBlock
      @webScriptObjectBlock.call(webview.windowScriptObject, webFrame)
    end
  end

  # - (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame
  def webView(webview, didClearWindowObject:webScriptObject, forFrame:webFrame)
    if @webScriptObjectBlock
      @webScriptObjectBlock.call(webScriptObject, webFrame)
    end
  end

  def setWebScriptObjectWithBlock(block)
    @webScriptObjectBlock = block
  end
end
