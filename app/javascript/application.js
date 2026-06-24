// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
document.addEventListener("turbo:load", () => {
  const flash = document.getElementById("flash-notice");

  if (flash) {
    setTimeout(() => {
      flash.remove();
    }, 3000);
  }
});