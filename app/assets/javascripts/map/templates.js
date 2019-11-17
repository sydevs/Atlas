const Templates = {
    resultContainerHtml(eventIndex, event) {
    return '<div class="result-container">'+
    '  <div class="event-info-container">'+
    '    <span id="eventName" class="event-name">'+(event.name || event.label)+'</span>'+
    '    <span id="eventAddress" class="event-address">'+(event.address_text || "")+'</span>'+
    '    <span class="time-details">'+
    '      <span id="timeDetailsDay" class="day">'+(event.recurrence_in_words || "")+'</span>'+
    '      |  '+
    '      <span id="timeDetailsTime" class="time">'+(event.formatted_start_end_time || "")+'</span>'+
    '    </span>'+
    '    </span>'+
    '  </div>'+
    '  <div class="event-actions-container">'+
    '    <div class="button-container">'+
    '      <button class="registerButton register-button" data-eventId="'+event.id+'">Register</button>'+
    '    </div>'+
    '    <div class="link-container">'+
    '      <a class="moreInfoLink more-info-link" data-eventId="'+event.id+'">'+
    '        More Info'+
    '      </a>'+
    '    </div>'+
    '  </div>'+
    '</div>'+
    '<span class="divider"></span>'; 
    }   
}