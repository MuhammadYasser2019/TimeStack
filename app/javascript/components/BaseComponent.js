import React from "react";
import {set_up_axios} from "../helpers/requestHelper";
import Snackbar from "@material-ui/core/Snackbar";
import {isEmpty} from "../helpers/validator";

import IconButton from '@material-ui/core/IconButton';
import CloseIcon from '@material-ui/icons/Close';


class BaseComponent extends React.Component {
  constructor(props){
      set_up_axios();
      super(props);
      this.state = {

      }
      this.handleSnackBarClose = this.handleSnackBarClose.bind(this);
  }

  handleSnackBarClose(){
    this.props.handleSnackbarClosed && this.props.handleSnackbarClosed();
  }

  render(){
    let message = this.props.message;
    return <React.Fragment>
      {!isEmpty(message) && <Snackbar  anchorOrigin={{
          vertical: 'bottom',
          horizontal: 'left',
        }} message={message} open={true} autoHideDuration={5000} onClose={()=>this.handleSnackBarClose()}  action={
          <React.Fragment>
            <IconButton size="small" aria-label="close" color="inherit" onClick={()=>this.handleSnackBarClose()}>
              <CloseIcon fontSize="small" />
            </IconButton>
          </React.Fragment>
        }/>}
      {this.props.children}
    </React.Fragment>
  }
}

export default BaseComponent
