require 'watir'
class Scraper
    attr_accessor :app_base_url, :app_current_url, :browser, :states, :time
    def initialize(app_base_url, time = 2)
        @app_base_url = app_base_url
        @app_current_url = @app_base_url
        @browser = Watir::Browser.new
        @states = []
        @time = time
        home
    end
    def save_state

    end
    def js_command(js)
        send_js(js)
        run_command
    end

    private
    def send_js(js = '', t = time)
        browser.execute_script(File.read(File.join(File.dirname(__FILE__), "../javascript/TransferElement.js")) + js)
        s(t)
    end
    def run_command
        instructions = decode_transfer_element
        if instructions.dig(:action, :type) == 'click'
            click(eval(instructions[:eval_string]))
        elsif instructions.dig(:action, :type) == 'entry'
            type(eval(instructions[:eval_string]), instructions.dig(:action, :send))
        end
    end
    def decode_transfer_element
        transfer_element = browser.span(id: 't-e')
        return instructions = { 
            action: { 
                type: transfer_element.inner_html.split('|')[0].split(': ')[0], 
                send: transfer_element.inner_html.split('|')[1].split(': ')[1] 
                }, 
            eval_string: create_eval_string(transfer_element.inner_html.split('|')[1]) 
        }
    end

    def create_eval_string(target_string)
        eval_string = "browser"
        target_string.split(',').each do |e|
            if !e.include?('html')
                if e.include?('#')
                    s = e.split('#')
                    eval_string = eval_string + ".#{s[0]}(id: '#{s[1]}')"
                elsif e.include?('.')
                    s = e.split('.')
                    eval_string = eval_string + ".#{s[0]}(class: '#{s[1..s.length].join(' ')}')"
                else
                    eval_string = eval_string + ".#{e}"
                end
            end
        end
        return eval_string
    end

    def get_element_text(tag_name, css_type = nil, css = nil)
        stmt = ""
        if css_type.include?('class')
            stmt = "browser.#{tag_name}(class: '#{css}').inner_html"
        elsif css_type.include?('id')
            stmt = "browser.#{tag_name}(id: '#{css}').inner_html"
        elsif css_type == nil
            stmt = "browser.#{tag_name}.inner_html"
        end
        eval(stmt).to_s.split(',')
    end

    def click(element, t = time)
        element.click
        s(t)
    end

    def type(element, entry, t = time/2)
        element.send_keys(entry)
        s(t)
    end

    def home(t = time*2)
        browser.goto(app_base_url)
        iframe_link = get_iframe(browser.body)
        if iframe_link != ''
            browser.goto("#{app_base_url.split('.com')[0]}.com#{iframe_link}")
        end
        s(t)
    end

    def visit(url = app_base_url, t = time)
        browser.goto(url)
        s(t)
    end

    def s(time)
        sleep time
    end

    def get_iframe(element)
        iframe_link = ''
        element.children.each do |e|
            if e.class != Watir::IFrame
                e.children.each do |c|
                    if c.class == Watir::IFrame
                        iframe_link = c.src
                    end
                end
            else
                iframe_link = e.src
            end
            break if iframe_link != ''
        end
        return iframe_link
    end

end
