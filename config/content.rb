TEXT_SLIDES = {
  :morning => {:header => "Hello, World;", :text => "Enjoy Breakfast"},
  :afternoon => {:header => "Lunch Time", :text => "Om nom, nom, nom <div><img src='http://nyan-cat.com/images/nyan-cat.gif'></div>"},
  :end => {:header => "end();", :text => "Thanks for coming"}
}

PAGES = [
	{ :header => "Game of Life Rules", :text => <<-eos
      <ul>
        <li>A live cell remains alive only if it has 2-3 live neighbours</li>
        <li>A dead cell becomes alive only if it has <strong>exactly</strong> live neighbours</li>
      </ul>
      eos
    },
	{ :header => "SOLID", :text => <<-eos
      <ul>
        <li><strong>S</strong>: Single Responsibility Principle</li>
        <li><strong>O</strong>: Open-Closed Principle</li>
        <li><strong>L</strong>: Liskov Substitution Principle</li>
        <li><strong>I</strong>: Interface Segregation Principle</li>
        <li><strong>D</strong>: Dependency Inversion Principle</li>
      </ul>
    eos
    },
    { :header => "DRY", :text => <<-eos
      <img src="http://img443.imageshack.us/img443/385/screenshot20111130at729.png">
    eos
    },
    { :header => "TDD", :text => <<-eos
      <h2>Test Driven Development</h2>
      <div style="color: red">RED</div>
      <div style="color: green">GREEN</div>
      <div style="color: red">REFACTOR</div>
    eos
    },
	{ :header => "4 Rules of Simple Design", :text => <<-eos
      <ol>
        <li>Works - Passes all the tests</li>
        <li>DRY - Minimizes duplication</li>
        <li>Expresses intent - Maximizes clarity</li>
        <li>Has fewer elements</li>
      </ol>
    eos
    },
	{ :header => "Hey! You holding the keyboard!", :text => <<-eos
      <h2>Do you really think that's a descriptive variable name?</h2>
    eos
    },
	{ :header => "Hey! You holding the keyboard!", :text => <<-eos
      <h2>Have you ever heard of OOP? From the looks of your code, I think not!</h2>
    eos
    },
]