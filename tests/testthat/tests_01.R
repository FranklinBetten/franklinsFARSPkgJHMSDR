library(testthat)
setwd(paste0(path.package(package = "franklinsFARSPkgJHMSDR","extdata/")))

# expect_that(x, is_true()) expect_true(x)
# expect_that(x, is_false()) expect_false(x)
# expect_that(x, is_a(y)) expect_is(x, y)
# expect_that(x, equals(y)) expect_equal(x, y)
# expect_that(x, is_equivalent_to(y)) expect_equivalent(x, y)
# expect_that(x, is_identical_to(y)) expect_identical(x, y)
# expect_that(x, matches(y)) expect_matches(x, y)
# expect_that(x, prints_text(y)) expect_output(x, y)
# expect_that(x, shows_message(y)) expect_message(x, y)
# expect_that(x, gives_warning(y)) expect_warning(x, y)
# expect_that(x, throws_error(y)) expect_error(x, y)

test_that("the make_filename fxn produces expected outputs", {

  expect_that(make_filename(2013), equals("accident_2013.csv.bz2"))
  expect_that(length(make_filename(2013)), equals(length("accident_2013.csv.bz2")))
  expect_that(make_filename(2013), is_a("character"))
})

test_that("fars_read works as expected and throws erros as expected", {

  expect_that(fars_read(make_filename(2013)),is_a("tbl_df"))
  expect_that(dim(fars_read(make_filename(2013))), equals(c(30202, 50)))

})

