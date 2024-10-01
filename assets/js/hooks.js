let Hooks = {};

Hooks.FocusFirstError = {
  mounted() {
    this.handleEvent("invalid_form", () => {
      const form = document.querySelector(".create-jobs-form");

      const firstErrorInput = form.querySelector("input");

      if (firstErrorInput && firstErrorInput.tagName === "INPUT") {
        firstErrorInput.focus();
        console.log("Focused on:", firstErrorInput);
      } else {
        console.log("No input with error found");
      }
    });
  },
};

export default Hooks;
