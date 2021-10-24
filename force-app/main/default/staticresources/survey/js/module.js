$(function(){

	//スムーススクロール
	$('a[href^="#"]').click(function(){
		//var gap = w>767 ? 93 : 78;
		var speed = 1000;
		var href= $(this).attr("href");
		var target = $(href == "#" || href == "" ? 'html' : href);
		var position = target.offset().top;// - gap;
		$("html, body").animate({scrollTop:position}, speed, "easeInOutQuart");
		return false;
	});

	//slick
	$('#banners,#banners_sp').slick({
	  slidesToShow: 1,
		arrows: true,
		dots: true
	});
	$('#payment_status_slider').slick({
	  slidesToShow: 1,
		arrows: true,
		dots: true
	});

	//メニュー
	$('.header_btn').on('click',function(){
		$('body').toggleClass('menu-open');
	});

	//faq
	$('#faqlist > li').on('click',function(){
		if(!$(this).hasClass('on')){
			$(this).addClass('on').siblings().removeClass('on');
			$($(this).find('a').data('faq')).addClass('on').siblings().removeClass('on');
		}
	});
	$('.faq_content dl dt').on('click',function(){
		$(this).parent().toggleClass('open');
	});

	//SPメニュー
	$('#SpMenu').on('click',function(){
		$('header nav').toggleClass('show');
	});

	//流れ説明開閉
	$('.steps_box_title').on('click',function(){
		$(this).toggleClass('open').next().toggleClass('open');
	});
	$('.steps_box_inner_tab li').on('click',function(){
		if(!$(this).hasClass('on')){
			$(this).addClass('on').siblings().removeClass('on');
			$($(this).data('tab')).addClass('show').removeClass('hide').siblings('.steps_box_inner_box').removeClass('show').addClass('hide');
		}
	});

	//フォーム
	$('#pgSurvey:fmSurvey:form_title,#pgSurvey:fmSurvey:form_content').keyup(function(){
		var count = $(this).val().length;
		$('#'+$(this).attr('id')+'_num span').text(count);
	});


});


var now;


$(window).on('load resize',function(){

	var w = $(window).width();
	var h = $(window).height();

	if(now !== w){

		if(w<768){
			$('#form_title_num').appendTo('.form_table th');
		}else{
			$('#form_title_num').appendTo('.form_table td');
		}

	}

	now = w;

});
