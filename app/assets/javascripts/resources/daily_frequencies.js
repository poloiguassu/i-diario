$(function () {
  window.classrooms = [];
  window.disciplines = [];
  window.avaliations = [];

  var $disciplineAbsenceFields = $(".discipline_absence_fields"),
      $globalAbsence = $("#daily_frequency_global_absence"),
      $examRuleNotFoundAlert = $('#exam-rule-not-found-alert');

  var fetchClassrooms = function (params, callback) {
    if (_.isEmpty(window.classrooms)) {
      $.getJSON(Routes.classrooms_pt_br_path(params)).always(function (data) {
        window.classrooms = data;
        callback(window.classrooms);
      });
    } else {
      callback(window.classrooms);
    }
  };

  var fetchDisciplines = function (params, callback) {
    if (_.isEmpty(window.disciplines)) {
      $.getJSON('/disciplinas?' + $.param(params)).always(function (data) {
        window.disciplines = data;
        callback(window.disciplines);
      });
    } else {
      callback(window.disciplines);
    }
  };

  var fetchAvaliations = function (params, callback) {
    if (_.isEmpty(window.avaliations)) {
      $.getJSON('/teacher_avaliations?' + $.param(params)).always(function (data) {
        window.avaliations = data;
        callback(window.avaliations);
      });
    } else {
      callback(window.avaliations);
    }
  };

  var fetchExamRule = function (params, callback) {
    $.getJSON('/exam_rules?' + $.param(params)).always(function (data) {
      callback(data);
    });
  };

  var $classroom  = $('#daily_frequency_classroom_id');
  var $discipline = $('#daily_frequency_discipline_id');
  var $avaliation = $('#daily_frequency_avaliation_id');


  $('#daily_frequency_unity_id').on('change', function (e) {
    var params = {
      filter: {
        by_unity: e.val
      },
      find_by_current_teacher: true
    };

    window.classrooms = [];
    window.disciplines = [];
    window.avaliations = [];
    $classroom.val('').select2({ data: [] });
    $discipline.val('').select2({ data: [] });
    $avaliation.val('').select2({ data: [] });

    if (!_.isEmpty(e.val)) {
      fetchClassrooms(params, function (classrooms) {
        var selectedClassrooms = _.map(classrooms, function (classroom) {
          return { id:classroom['id'], text: classroom['description'] };
        });

        $classroom.select2({
          data: selectedClassrooms
        });
      });
    }
  });

  var checkExamRule = function(params){
    fetchExamRule(params, function(data){
      var examRule = data.exam_rule;
      $('form input[type=submit]').removeClass('disabled');
      if(!$.isEmptyObject(examRule)){
        $examRuleNotFoundAlert.addClass('hidden');

        if(examRule.frequency_type == 2 || examRule.allow_frequency_by_discipline){
          $globalAbsence.val(0);
          $disciplineAbsenceFields.show();
        }else{
          $globalAbsence.val(1);
          $disciplineAbsenceFields.hide();
          $discipline.val('').select2({ data: [] })
        }

      }else{
        $globalAbsence.val(0);
        $disciplineAbsenceFields.hide();

        // Display alert
        $examRuleNotFoundAlert.removeClass('hidden');

        // Disable form submit
        $('form input[type=submit]').addClass('disabled');
      }
    });
  }

  $classroom.on('change', function (e) {
    var params = {
      classroom_id: e.val
    };

    window.disciplines = [];
    window.avaliations = [];
    $discipline.val('').select2({ data: [] });
    $avaliation.val('').select2({ data: [] });

    if (!_.isEmpty(e.val)) {

      checkExamRule(params);

      fetchDisciplines(params, function (disciplines) {
        var selectedDisciplines = _.map(disciplines, function (discipline) {
          return { id:discipline['id'], text: discipline['description'] };
        });

        $discipline.select2({
          data: selectedDisciplines
        });
      });
    }
  });

  $('#daily_frequency_discipline_id').on('change', function (e) {
    var params = {
      discipline_id: e.val,
      classroom_id: $classroom.val()
    };

    window.avaliations = [];
    $avaliation.val('').select2({ data: [] });

    if (!_.isEmpty(e.val)) {
      fetchAvaliations(params, function (avaliations) {
        var selectedAvaliations = _.map(avaliations, function (avaliation) {
          return { id: avaliation['id'], text: avaliation['description'] };
        });

        $avaliation.select2({
          data: selectedAvaliations
        });
      });
    }
  });

  $disciplineAbsenceFields.hide();

  // fix to checkboxes work correctly
  $('[name="daily_frequency_student[][present]"][type=hidden]').remove();

  if($classroom.length && $classroom.val().length){
    checkExamRule({classroom_id: $classroom.val()});
  }

  $("[name='daily_frequency_student[][present]']").on("change", function(){
    var student_id = $(this).closest("td").find("[name='daily_frequency_student[][student_id]']").val();
    var daily_frequency_id = $(this).closest("td").find("[name='daily_frequency_student[][daily_frequency_id]']").val();
    var dependence = $(this).closest("td").find("[name='daily_frequency_student[][dependence]']").val();
    var present = $(this).prop("checked");

    var params = {
      student_id: student_id,
      daily_frequency_id: daily_frequency_id,
      present: present,
      dependence: dependence
    };

    $.post(Routes.create_or_update_daily_frequency_students_pt_br_path(), params, function(data){
    }, "json");
  });
});
